// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, console2} from "forge-std/Test.sol";
import {InterestRate} from "../src/Counter.sol";

contract InterestRateTest is Test {
    InterestRate public interestRate;
    uint256 rate;

    function setUp() public {
        interestRate = new InterestRate();
    }

    function testGetInterestRate public{
        rate = interestRate.getInterestRate();
        console.log(rate)
    }