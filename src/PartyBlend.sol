// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Need to add the UUPSUpgradeable contract to the project when you're ready:
// import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Eventually, we will build this with Party Protocol but the current version will use some of
// the concepts we used in Bonkler Bidder and Bonkler Wallet

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";

// The goal of Party Blend is to raise NFTs and then use the NFTs on Blur's Blend Protocol
contract PartyBlend is ReentrancyGuard, Ownable {
    event EthReceived(address indexed sender, uint256 amount);
    event EthWithdrawn(address indexed sender, uint256 amount);

    mapping(address => uint256) private ethDeposits;

    constructor() {
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
}
