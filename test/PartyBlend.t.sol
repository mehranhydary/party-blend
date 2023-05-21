// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PartyBlend} from "../src/PartyBlend.sol";

contract PartyBlendTest is Test {
    PartyBlend partyBlend;

    function setUp() public {
        partyBlend = new PartyBlend();
    }
}
