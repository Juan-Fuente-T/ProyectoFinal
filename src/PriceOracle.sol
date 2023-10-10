// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import {FeedRegistryInterface} from "./libraries/FeedRegistryInterface.sol";

//address BTC/ETH 0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22
//address ETH/LINK 0xb4c4a493AB6356497713A78FFA6c60FB53517c63


contract PriceOracle {
    address public immutable ethContractAddress;
    address public immutable btcContractAddress;
    address public immutable linkContractAddress;
    address public immutable usdtContractAddress;
    address public immutable adaContractAddress


    uint256 public BTC_ETHPrice;
    uint256 public ETH_BTCPrice;
    uint256 public LINK_ETHPrice;
    uint256 public ETH_LINKPrice;
    uint256 public USDT_ETHPrice;
    uint256 public ETH_USDTPrice;
    uint256 public ADA_ETHPrice;
    uint256 public ETH_ADAPrice;


    FeedRegistryInterface internal immutable priceFeedBTC_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_BTC;
    FeedRegistryInterface internal immutable priceFeedLINK_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_LINK;
    FeedRegistryInterface internal immutable priceFeedUSDT_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_USDT;
    FeedRegistryInterface internal immutable priceFeedADA_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_ADA;

    
    constructor(
        address _priceFeedBTC_ETH, 
        address _priceFeedETH_BTC, 
        address _priceFeedLINK_ETH,
        address _priceFeedETH_LINK,
        address _priceFeedUSDT_ETH,
        address _priceFeedETH_USDT,
        address _priceFeedADA_ETH,
        address _priceFeedETH_ADA,
        address _ethContractAddress,
        address _btcContractAddress,
        address _linkContractAddress,
        address _usdtContractAddress,
        address _adaContractAddress
        ){
        priceFeedBTC_ETH = FeedRegistryInterface(_priceFeedBTC_ETH);
        priceFeedETH_BTC = FeedRegistryInterface(_priceFeedETH_BTC);
        priceFeedLINK_ETH= FeedRegistryInterface(_priceFeedLINK_ETH);
        priceFeedETH_LINK= FeedRegistryInterface(_priceFeedETH_LINK);
        priceFeedUSDT_ETH= FeedRegistryInterface(_priceFeedLINK_ETH);
        priceFeedETH_USDT= FeedRegistryInterface(_priceFeedETH_LINK);
        priceFeedADA_ETH= FeedRegistryInterface(_priceFeedLINK_ETH);
        priceFeedETH_ADA= FeedRegistryInterface(_priceFeedETH_LINK);
        ethContractAddress = _ethContractAddress;
        btcContractAddress = _btcContractAddress;
        linkContractAddress = _linkContractAddress;
        usdtContractAddress = _usdtContractAddress;
        adaContractAddress = _adaContractAddress;

    }

    function getBTC_ETHPrice() public view returns(uint256){
        (, int256 btc_ethPrice, , , ) = priceFeedBTC_ETH.latestRoundData(btcContractAddress, ethContractAddress);
        BTC_ETHPrice = uint256(btc_ethPrice);
        return BTC_ETHPrice;
    }
    function getETH_BTCPrice() public view returns(uint256){
        (, int256 eth_btcPrice, , , ) = priceFeedETH_BTC.latestRoundData(ethContractAddress, btcContractAddress);
        ETH_BTCPrice= uint256(eth_btcPrice);
        return ETH_BTCPrice;
    }


    function getLINK_ETHPrice() public view returns(uint256){
        (, int256 link_ethPrice, , , ) = priceFeedLINK_ETH.latestRoundData(linkContractAddress, ethContractAddress);
        LINK_ETHPrice = uint256(link_ethPrice);
        return LINK_ETHPrice;
    }
    function getETH_LINKPrice() public view returns(uint256){
        (, int256 eth_linkPrice, , , ) = priceFeedETH_LINK.latestRoundData(ethContractAddress, linkContractAddress);
        ETH_LINKPrice = uint256(eth_linkPrice);
        return ETH_LINKPrice;
    }
    function getUSDT_ETHPrice() public view returns(uint256){
        (, int256 usdt_ethPrice, , , ) = priceFeedUSDT_ETH.latestRoundData(usdtContractAddress, ethContractAddress);
        USDT_ETHPrice = uint256(usdt_ethPrice);
        return USDT_ETHPrice;
    }
    function getETH_USDTPrice() public view returns(uint256){
        (, int256 eth_usdtPrice, , , ) = priceFeedETH_USDT.latestRoundData(ethContractAddress, usdtContractAddress);
        ETH_USDTPrice = uint256(eth_usdtPrice);
        return ETH_USDTPrice;
    }
    function getADA_ETHPrice() public view returns(uint256){
        (, int256 ada_ethPrice, , , ) = priceFeedADA_ETH.latestRoundData(adaContractAddress, ethContractAddress);
        ADA_ETHPrice = uint256(ada_ethPrice);
        return ADA_ETHPrice;
    }
    function getETH_ADAPrice() public view returns(uint256){
        (, int256 eth_adaPrice, , , ) = priceFeedETH_ADA.latestRoundData(ethContractAddress, adaContractAddress);
        ETH_ADAPrice = uint256(eth_adaPrice);
        return ETH_ADAPrice;
    }

}