// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, console2} from "forge-std/Test.sol";
import {PriceOracle} from "../src/PriceOracle-copia.sol";
import {PriceFeedMock} from "../src/PriceFeedMock.sol";

contract PriceOracleTest is Test {
   PriceOracle priceOracleTest;
   PriceFeedMock priceFeedMock;

   uint256 mainnetFork;

   string MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3';

    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29
    function setUp() public {
      mainnetFork = vm.createFork(MAINNET_RPC_URL);
      vm.selectFork(mainnetFork);
      priceFeedMock = new PriceFeedMock();
      address _feedRegistryInterface = makeAddr("_feedRegistryInterface");
      address _ethContractAddress = makeAddr("_ethContractAddress"); 
      address _btcContractAddress = makeAddr("_btcContractAddress"); 
      address _linkContractAddress = makeAddr("_linkContractAddress"); 
      address _usdtContractAddress = makeAddr("_usdtContractAddress"); 
      address _adaContractAddress = makeAddr("_adaContractAddress"); 
      priceOracleTest = new PriceOracle(priceFeedMock, _feedRegistryInterface, _ethContractAddress, _btcContractAddress, _linkContractAddress, _usdtContractAddress, _adaContractAddress);
      console2.logAddress(_ethContractAddress);
    }
   function testPriceOracle() public{
      
      //uint256 interestRate = interestRatesTest.getInterestRate();
      uint256 priceOracle = priceOracleTest.getPriceFromChainlink();
      assertEq(200, priceOracle);
      console.log(priceOracle);
      address eth = priceOracleTest.getEthAddress();
      console2.logAddress(eth);
      address btc = priceOracleTest.getBtcAddress();
      console2.logAddress(btc);
      address link = priceOracleTest.getLinkAddress();
      console2.logAddress(link);
      address usdt = priceOracleTest.getUsdtAddress();
      console2.logAddress(usdt);
      address ada = priceOracleTest.getAdaAddress();
      console2.logAddress(ada);

      uint256 eth_BtcPrice = priceOracleTest.testGetETH_BTCPrice();
      assertEq(1000, eth_BtcPrice);
      console.log(eth_BtcPrice);
      uint256 btc_EthPrice = priceOracleTest.testGetBTC_ETHPrice();
      assertEq(2000, btc_EthPrice);
      console.log(btc_EthPrice);
      uint256 eth_LinkPrice = priceOracleTest.testGetETH_LINKPrice();
      assertEq(3000, eth_LinkPrice);
      console.log(eth_LinkPrice);
      uint256 link_EthPrice = priceOracleTest.testGetLINK_ETHPrice();
      assertEq(4000, link_EthPrice);
      console.log(link_EthPrice);
      uint256 eth_UsdtPrice = priceOracleTest.testGetETH_USDTPrice();
      assertEq(5000, eth_UsdtPrice);
      console.log(eth_UsdtPrice);
      uint256 usdt_EthPrice = priceOracleTest.testGetUSDT_ETHPrice();
      assertEq(6000, usdt_EthPrice);
      console.log(usdt_EthPrice);
      uint256 eth_AdaPrice = priceOracleTest.testGetETH_ADAPrice();
      assertEq(7000, eth_AdaPrice);
      console.log(eth_AdaPrice);
      uint256 ada_EthPrice = priceOracleTest.testGetADA_ETHPrice();
      assertEq(8000, ada_EthPrice);
      console.log(ada_EthPrice);

   
      

   }
}