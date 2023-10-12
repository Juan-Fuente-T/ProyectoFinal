// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import { PriceOracle } from "./PriceOracle.sol";

contract PruebaImport{
    PriceOracle public priceOracle;
    
    constructor(address _priceOracle){
        priceOracle = PriceOracle(_priceOracle);
    }

    function setPriceOracle(address _priceOracle) public{
    priceOracle = PriceOracle(_priceOracle);
    }

    uint256 price = priceOracle.getETH_LINKPrice();
    address ethAddress = priceOracle.getEthAddress(); 
}