// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, console2} from "forge-std/Test.sol";
import {InterestRates} from "../src/InterestRates.sol";

contract InterestRateTest is Test {
    InterestRates public interestRates;
    uint256 rate;

    /*function setUp() public {
        interestRates = new InterestRates();
    }*/

    function testGetInterestRate() public{
        rate = interestRates.getInterestRate();
        console.log(rate);
    }
}