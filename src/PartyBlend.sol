// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {CrowdFund} from "party-protocol/crowdfund/CrowdFund.sol";

contract PartyBlend is CrowdFund, UUPSUpgradeable {}
