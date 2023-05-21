// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Need to add the UUPSUpgradeable contract to the project when you're ready:
// import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Eventually, we will build this with Party Protocol but the current version will use some of
// the concepts we used in Bonkler Bidder and Bonkler Wallet

// The goal of Party Blend is to raise NFTs and then use the NFTs on Blur's Blend Protocol
contract PartyBlend {
    event NftsReceived(address indexed sender);
    event NftsWithdrawn(address indexed sender, uint256 amount);

    constructor() {}
}
