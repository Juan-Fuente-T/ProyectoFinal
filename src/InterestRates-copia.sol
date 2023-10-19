// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {PriceFeedMock} from "./PriceFeedMock.sol";

contract InterestRates {
    uint256 public interestRate;
    uint256 public borrowInterestRate;

    PriceFeedMock internal priceFeedMock;

    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal  borrowPriceFeed;



    //address oracle rates feeds chainlink 
    //address _priceFeed(ETH staking ATR?) = 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29
    //adrres _borrowPriceFeed (BTC week Curve 2) = 0x39545d0c11CD62d787bB971B6a802150e1f54D8f
    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    constructor(address _priceFeed, address _borrowPriceFeed, PriceFeedMock _priceFeedMock){
        priceFeed = AggregatorV3Interface(_priceFeed);
        borrowPriceFeed = AggregatorV3Interface(_borrowPriceFeed);
        priceFeedMock = PriceFeedMock(_priceFeedMock);
    }

    function getDataFromChainlink() public view returns (uint256) {
        // Llamar a la función en el mock de Chainlink para obtener los datos
        return priceFeedMock.getData();
    }

    function getInterestRate() public  returns(uint256){
        //(, int256 answer, , , ) = priceFeed.latestRoundData();
        //interestRate = uint256(answer);
        interestRate = priceFeedMock.getData();
        return interestRate;
    }
    function getInterestBorrow() public  returns(uint256){
        //(, int256 answer, , , ) = borrowPriceFeed.latestRoundData();
        //borrowInterestRate = uint256(answer);
        borrowInterestRate = priceFeedMock.getDataFeedRegistry();
        return borrowInterestRate;
    }
}