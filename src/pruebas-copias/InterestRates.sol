// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import {AggregatorV3Interface} from "../libraries/AggregatorV3Interface.sol";

contract InterestRates {
    uint256 public interestRate;
    uint256 public borrowInterestRate;

    AggregatorV3Interface internal immutable priceFeed;
    AggregatorV3Interface internal immutable borrowPriceFeed;

    //address oracle rates feeds chainlink
    //address _priceFeed(ETH staking ATR?) = 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29
    //adrres _borrowPriceFeed (BTC week Curve 2) = 0x39545d0c11CD62d787bB971B6a802150e1f54D8f
    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    constructor(address _priceFeed, address _borrowPriceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        borrowPriceFeed = AggregatorV3Interface(_borrowPriceFeed);
    }

    function getInterestRate() public returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        interestRate = uint256(answer);
        return interestRate;
    }

    function getInterestBorrow() public returns (uint256) {
        (, int256 answer, , , ) = borrowPriceFeed.latestRoundData();
        borrowInterestRate = uint256(answer);
        return borrowInterestRate;
    }
}
