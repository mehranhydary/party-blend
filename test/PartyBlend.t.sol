// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PartyBlend} from "../src/PartyBlend.sol";
import {ERC721Mock} from "openzeppelin-contracts/mocks/ERC721Mock.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract PartyBlendTest is Test {
    PartyBlend partyBlend;
    ERC721Mock mockERC721;

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

    function test_depositIntoBlur() public {}
}
