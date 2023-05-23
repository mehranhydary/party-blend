// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PartyBlend} from "../src/PartyBlend.sol";
import {IBlurPool} from "../src/interfaces/IBlurPool.sol";
import {ERC721Mock} from "openzeppelin-contracts/mocks/ERC721Mock.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract PartyBlendTest is Test {
    PartyBlend partyBlend;
    ERC721Mock mockERC721;
    address MILADY_TOKEN = 0x5Af0D9827E0c53E4799BB226655A1de152A425a5;
    address MILADY_WHALE = 0xB35248FeEB246b850Fac690a1BEaF5130dC71894;

    function setUp() public {
        mockERC721 = new ERC721Mock("Mock NFT", "MOCK");
        mockERC721.mint(msg.sender, 0);
        mockERC721.mint(msg.sender, 1);
        partyBlend = new PartyBlend(address(mockERC721));
    }

    function test_addEth() public {
        uint256 amount = 1000;
        vm.prank(msg.sender);
        (bool isTransferred, ) = address(partyBlend).call{value: amount}("");
        assert(isTransferred);
        assertEq(address(partyBlend).balance, amount);
        assertEq(partyBlend.getEthDepositAmount(msg.sender), amount);
    }

    function test_removeEth() public {
        uint256 amount = 1000;
        vm.prank(msg.sender);
        (bool isTransferred, ) = address(partyBlend).call{value: amount}("");
        assert(isTransferred);
        assertEq(address(partyBlend).balance, amount);
        assertEq(partyBlend.getEthDepositAmount(msg.sender), amount);
        vm.prank(msg.sender);
        partyBlend.withdrawEth(amount);
        assertEq(address(partyBlend).balance, 0);
        assertEq(partyBlend.getEthDepositAmount(msg.sender), 0);
    }

    function test_depositNft() public {
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 0;
        vm.startPrank(msg.sender);
        ERC721(address(mockERC721)).approve(address(partyBlend), 0);
        partyBlend.depositNft(tokenIds);
        vm.stopPrank();
        assertEq(partyBlend.nftDeposits(msg.sender), 1);
    }

    function test_depositNfts() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        vm.startPrank(msg.sender);
        ERC721(address(mockERC721)).setApprovalForAll(
            address(partyBlend),
            true
        );
        partyBlend.depositNft(tokenIds);
        vm.stopPrank();
        assertEq(partyBlend.nftDeposits(msg.sender), 2);
    }

    function test_withdrawNfts() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        vm.startPrank(msg.sender);
        ERC721(address(mockERC721)).setApprovalForAll(
            address(partyBlend),
            true
        );
        partyBlend.depositNft(tokenIds);
        assertEq(partyBlend.nftDeposits(msg.sender), 2);
        partyBlend.withdrawNfts(tokenIds);
        vm.stopPrank();
        assertEq(partyBlend.nftDeposits(msg.sender), 0);
        assertEq(mockERC721.ownerOf(0), msg.sender);
        assertEq(mockERC721.ownerOf(1), msg.sender);
    }

    function test_depositIntoBlur() public {
        uint256 amount = 1 ether;
        vm.startPrank(msg.sender);
        (bool isTransferred, ) = address(partyBlend).call{value: amount}("");
        assert(isTransferred);
        partyBlend.depositEthIntoBlur(amount);
        vm.stopPrank();
        assertEq(
            IBlurPool(0x0000000000A39bb272e79075ade125fd351887Ac).balanceOf(
                address(partyBlend)
            ),
            amount
        );
    }

    function test_withdrawDepositFromBlur() public {
        uint256 amount = 1 ether;
        vm.startPrank(msg.sender);
        (bool isTransferred, ) = address(partyBlend).call{value: amount}("");
        assert(isTransferred);
        partyBlend.depositEthIntoBlur(amount);
        assertEq(
            IBlurPool(0x0000000000A39bb272e79075ade125fd351887Ac).balanceOf(
                address(partyBlend)
            ),
            amount
        );
        partyBlend.withdrawEthFromBlur(amount);
        vm.stopPrank();
        assertEq(
            IBlurPool(0x0000000000A39bb272e79075ade125fd351887Ac).balanceOf(
                address(partyBlend)
            ),
            0
        );
    }

    function test_addMiladysToContract() public {
        ERC721 milady = ERC721(MILADY_TOKEN);
        partyBlend = new PartyBlend(MILADY_TOKEN);
        vm.startPrank(MILADY_WHALE);
        uint256[] memory tokenIds = new uint256[](2);
        ERC721(address(MILADY_TOKEN)).setApprovalForAll(
            address(partyBlend),
            true
        );
        tokenIds[0] = uint256(
            0x000000000000000000000000000000000000000000000000000000000000079E
        );
        tokenIds[1] = uint256(
            0x00000000000000000000000000000000000000000000000000000000000005E0
        );
        partyBlend.depositNft(tokenIds);
        vm.stopPrank();
        assertEq(partyBlend.nftDeposits(MILADY_WHALE), 2);
        assertEq(milady.balanceOf(address(partyBlend)), 2);
    }

    function test_borrowAgainstMiladys() public {
        ERC721 milady = ERC721(MILADY_TOKEN);
        partyBlend = new PartyBlend(MILADY_TOKEN);
        vm.startPrank(MILADY_WHALE);
        uint256[] memory tokenIds = new uint256[](2);
        ERC721(address(MILADY_TOKEN)).setApprovalForAll(
            address(partyBlend),
            true
        );
        tokenIds[0] = uint256(
            0x000000000000000000000000000000000000000000000000000000000000079E
        );
        tokenIds[1] = uint256(
            0x00000000000000000000000000000000000000000000000000000000000005E0
        );
        partyBlend.depositNft(tokenIds);
        vm.stopPrank();
        assertEq(partyBlend.nftDeposits(MILADY_WHALE), 2);
        assertEq(milady.balanceOf(address(partyBlend)), 2);

        // New code!
        // Need auction data before we can make on chain transactions... see if triple a has a solution
    }
}
