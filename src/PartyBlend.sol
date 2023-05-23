// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Need to add the UUPSUpgradeable contract to the project when you're ready

// Eventually, we will build this with Party Protocol but the current version will use some of
// the concepts we used in Bonkler Bidder and Bonkler Wallet

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {IBlurPool} from "./interfaces/IBlurPool.sol";
import {IBlend} from "./interfaces/IBlend.sol";
import {Pair} from "caviar/Pair.sol";

// import {CaviarZapRouter} from "caviar/CaviarZapRouter.sol";

// The goal of Party Blend is to raise NFTs and then use the NFTs on Blur's Blend Protocol
// Can only handle one NFT collection at a time
contract PartyBlend is ReentrancyGuard, Ownable, ERC721TokenReceiver {
    address public nftAddress;
    mapping(address => uint256) public ethDeposits;
    mapping(address => uint256) public nftDeposits;

    event EthReceived(address indexed sender, uint256 amount);
    event EthWithdrawn(address indexed sender, uint256 amount);
    event NftDeposited(address indexed sender, uint256 tokenId);

    constructor(address _nftAddress) {
        nftAddress = _nftAddress;
        transferOwnership(msg.sender);
    }

    receive() external payable {
        ethDeposits[msg.sender] += msg.value;
        emit EthReceived(msg.sender, msg.value);
    }

    function withdrawEth(uint256 amount) external nonReentrant {
        require(amount <= address(this).balance, "Not enough ETH in contract");
        require(amount <= ethDeposits[msg.sender], "Not enough ETH deposited");
        payable(msg.sender).transfer(amount);
        ethDeposits[msg.sender] -= amount;
        emit EthWithdrawn(msg.sender, amount);
    }

    function getEthDepositAmount(
        address account
    ) external view returns (uint256) {
        return ethDeposits[account];
    }

    function depositNft(uint256[] memory tokenIds) external {
        require(tokenIds.length > 0, "Must deposit at least one token");
        for (uint256 i = 0; i < tokenIds.length; ) {
            ERC721(nftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );
            nftDeposits[msg.sender] += 1;
            emit NftDeposited(msg.sender, tokenIds[i]);
            unchecked {
                i++;
            }
        }
    }

    // Need to always specify the tokens you want to withdraw
    // Note: Do we need to add restrictions re. who can withdraw what token id?
    function withdrawNfts(uint256[] memory tokenIds) external {
        require(tokenIds.length > 0, "Must withdraw at least one token");
        require(tokenIds.length <= nftDeposits[msg.sender], "Not enough NFTs");
        for (uint256 i = 0; i < tokenIds.length; ) {
            ERC721(nftAddress).safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i]
            );
            nftDeposits[msg.sender] -= 1;
            unchecked {
                i++;
            }
        }
    }

    function depositEthIntoBlur(uint256 amount) external {
        require(amount <= address(this).balance, "Not enough ETH in contract");
        require(amount <= ethDeposits[msg.sender], "Not enough ETH deposited");
        IBlurPool(0x0000000000A39bb272e79075ade125fd351887Ac).deposit{
            value: amount
        }();
    }

    function withdrawEthFromBlur(uint256 amount) external {
        IBlurPool blurPool = IBlurPool(
            0x0000000000A39bb272e79075ade125fd351887Ac
        );
        require(
            amount <= blurPool.balanceOf(address(this)),
            "Not enough ETH deposited"
        );
        blurPool.withdraw(amount);
    }

    function borrowEthAgainstNfts() external {
        // Only do this if not approved already
        ERC721(address(nftAddress)).setApprovalForAll(
            address(0x29469395eAf6f95920E59F858042f0e28D98a20B), // Blend address
            true
        );
        // IBlend(0x29469395eAf6f95920E59F858042f0e28D98a20B).borrow(
        //     offer,
        //     signature,
        //     loanAmount,
        //     collateralId
        // );
    }

    function addLpToCaviar(uint256[] calldata tokenIds) external {
        // Approve the router contract
        ERC721(address(nftAddress)).setApprovalForAll(
            address(0x6689679dAB35fb3Fc50bb4E5fD82C86A62a2cb8D), // Milady pair address
            true
        );
        Pair miladyPair = Pair(0x6689679dAB35fb3Fc50bb4E5fD82C86A62a2cb8D);
        // Call: buyAndAdd in the Router contract or wrap, add, etc. via Pair contract
        // Need to use the Caviar API to generate the order data
    }
}
