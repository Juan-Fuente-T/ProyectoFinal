// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";

contract InterestRates {
    uint256 public interestRate;
    uint256 public borrowInterestRate;

    AggregatorV3Interface internal immutable priceFeed;
    AggregatorV3Interface internal immutable borrowPriceFeed;



    //address oracle rates feeds chainlink 
    //address _priceFeed = 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29
    //adrres _borrowPriceFeed =

    constructor(address _priceFeed, address _borrowPriceFeed){
        priceFeed = AggregatorV3Interface(_priceFeed);
        borrowPriceFeed = AggregatorV3Interface(_borrowPriceFeed)
    }

    function getInterestRate() public view returns(uint256){
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        interestRate = uint256(answer);
        return interestRate;
    }
    function getInterestBorrow() public view return(uint256){
        (, int256 answer, , , ) = borrowPricefeed.latestRoundData();
        borrowInterestRate = uint256(answer);
        return borrowInterestRate;
    }
}