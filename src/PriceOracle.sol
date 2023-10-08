// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import {FeedRegistryInterface} from "./libraries/FeedRegistryInterface.sol";

//address BTC/ETH 0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22
//address ETH/LINK 0xb4c4a493AB6356497713A78FFA6c60FB53517c63


contract PriceOracle {
    uint256 public ETH_BTCPrice;
    uint256 public BTC_ETHPrice;
    uint256 public LINK_ETHPrice;
    uint256 public ETH_LINKPrice;


    FeedRegistryInterface internal immutable priceFeedETH_BTC;
    FeedRegistryInterface internal immutable priceFeedBTC_ETH;
    FeedRegistryInterface internal immutable priceFeedLINK_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_LINK;


    constructor(address _priceFeedETH_BTC, address _priceFeedBTC_ETH, address _piceFeedLINK_ETH,address _piceFeedETH_LINK){
        priceFeedETH_BTC = FeedRegistryInterface(_priceFeedETH_BTC);
        priceFeedBTC_ETH = FeedRegistryInterface(_priceFeedBTC_ETH);
        priceFeedLINK_ETH= FeedRegistryInterface(_priceFeedLINK_ETH);
        priceFeedETH_LINK= FeedRegistryInterface(_priceFeedETH_LINK);
    }

    function getETH_BTCPrice() public view returns(uint256){
        (, int256 eth_btcPrice, , , ) = priceFeedETH_BTC.latestRoundData(ETH, BTC);
        ETH_BTCPrice= uint256(eth_btcPrice);
        return ETH_BTCPrice;
    }

    function getBTC_ETHPrice() public view returns(uint256){
        (, int256 btc_ethPrice, , , ) = priceFeedBTC_ETH.latestRoundData(BTC, ETH);
        BTC_ETHPrice = uint256(btc_ethPrice);
        return BTC_ETHPrice;
    }

    function getLINK_ETHPrice() public view returns(uint256){
        (, int256 link_ethPrice, , , ) = priceFeedLINK_ETH.latestRoundData(LINK, ETH);
        LINK_ETHPrice = uint256(link_ethPrice);
        return LINK_ETHPrice;
    }
    function getETH_LINKPrice() public view returns(uint256){
        (, int256 eth_linkPrice, , , ) = priceFeedETH_LINK.latestRoundData(ETH, LINK);
        ETH_LINKPrice = uint256(eth_linkPrice);
        return ETH_LINKPrice;
    }

}