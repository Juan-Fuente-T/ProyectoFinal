// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract InterestRates {
    uint256 public interestRate;

    AggregatorV3Interface internal immutable priceFeed;

    //address oracle rates feeds chainlink 
    //address _priceFeed = 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    constructor(address _priceFeed){
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getInterestRate() public returns(uint256){
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        interestRate = uint256(answer);
        return interestRate;
    }
}