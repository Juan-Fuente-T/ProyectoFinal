// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PriceFeedMock{

    address _feedRegistryInterfaceAddress = 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
    address _ethContractAddress = 0x0000000000000000000000000000000000000001;
    address _btcContractAddress = 0x0000000000000000000000000000000000000002;
    address _linkContractAddress = 0x0000000000000000000000000000000000000003;
    address _usdtContractAddress = 0x0000000000000000000000000000000000000004;
    address _adaContractAddress = 0x0000000000000000000000000000000000000005;
    //address _feedResgistryInterface = 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
    //feedResgistryInterface Address?: 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
    function getDataFeedRegistryEth_Btc() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 1;
    }
    function getDataFeedRegistryBtc_Eth() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 2;
    }
    function getDataFeedRegistryEth_Link() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 3;
    }
    function getDataFeedRegistryLink_Eth() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 4;
    }
    function getDataFeedRegistryEth_Usdt() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 5;
    }
    function getDataFeedRegistryUsdt_Eth() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 6;
    }
    function getDataFeedRegistryEth_Ada() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 7;
    }
    function getDataFeedRegistryAda_Eth() public pure returns (uint256) {
    // Devolver datos predefinidos
    return 8;
    }


    function getPriceFeedRegistryAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _feedRegistryInterfaceAddress;
    }
    function getEthContractAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _ethContractAddress;
    }
    function getBtcContractAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _btcContractAddress;
    }
    function getLinkContractAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _linkContractAddress;
    }
    function getUsdtContractAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _usdtContractAddress;
    }
    function getAdaContractAddress() public view returns (address) {
    // Devolver datos predefinidos
    return _adaContractAddress;
    }

    function getData() public pure returns (uint256) {
    // Devolver datos predefinidos para rates
    return 50 * 10 ** 16;
    }
    function getDataFeedRegistry() public pure returns (uint256) {
    // Devolver datos predefinidos para relacion de precios entre dos cryptomonedas
    return 75 * 10 ** 16;
    }
}


