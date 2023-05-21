// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PartyBlend} from "../src/PartyBlend.sol";

contract PartyBlendTest is Test {
    PartyBlend partyBlend;

    function setUp() public {
        partyBlend = new PartyBlend();
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
}
