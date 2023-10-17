// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//Se importa el contrato del oráculo de  Chainlink
import {FeedRegistryInterface} from "./libraries/FeedRegistryInterface.sol";
import {PriceFeedMock} from "./PriceFeedMock.sol";

//address BTC/ETH 0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22
//address ETH/LINK 0xb4c4a493AB6356497713A78FFA6c60FB53517c63

//SE NECESITAN LAS ADDRESS DE LOS TOKEN, BTC, LINK, ETC

contract PriceOracle {

    address public immutable ethContractAddress;
    address public immutable btcContractAddress;
    address public immutable linkContractAddress;
    address public immutable usdtContractAddress;
    address public immutable adaContractAddress;
    
    FeedRegistryInterface internal  registry;

    PriceFeedMock internal  priceFeedMock;
    /*address[] feedAddresses = (
        FeedRegistryInterface.latestRoundData(btcContractAddress, ethContractAddress),
        FeedRegistryInterface.latestRoundData(ethContractAddress, btcContractAddress),
        FeedRegistryInterface.latestRoundData(linkContractAddress, ethContractAddress),
        FeedRegistryInterface.latestRoundData(ethContractAddress, linkContractAddress),
        FeedRegistryInterface.latestRoundData(usdtContractAddress, ethContractAddress),
        FeedRegistryInterface.latestRoundData(ethContractAddress, usdtContractAddress),
        FeedRegistryInterface.latestRoundData(adaContractAddress, ethContractAddress),
        FeedRegistryInterface.latestRoundData(ethContractAddress, adaContractAddress)
    );
        
    string[llenar con las address de lostokens] pairs;*/
    
    //mapping(string => FeedRegistryInterface) public priceFeeds;

    constructor(
        PriceFeedMock _priceFeedMock,
        address _feedRegistryInterfaceAddress,
        address _ethContractAddress,
        address _btcContractAddress,
        address _linkContractAddress,
        address _usdtContractAddress,
        address _adaContractAddress
        ) {
        priceFeedMock = PriceFeedMock(_priceFeedMock);
        registry = FeedRegistryInterface(_feedRegistryInterfaceAddress);
        ethContractAddress = _ethContractAddress;
        btcContractAddress = _btcContractAddress;
        linkContractAddress = _linkContractAddress;
        usdtContractAddress = _usdtContractAddress;
        adaContractAddress = _adaContractAddress;
        }
    
        /*function getTokenAdresses() public view returns (
            address ethAddress, 
            address btcAddress, 
            address linkAddress, 
            address usdtAddress, 
            address adaAddress
            ){
            ethAddress = ethContractAddress;
            btcAddress = btcContractAddress;
            linkAddress = linkContractAddress;
            usdtAddress = usdtContractAddress;
            adaAddress = adaContractAddress;
        } */

    
    function getPriceFromChainlink() public view returns (uint256) {
        // Llamar a la función en el mock de Chainlink para obtener los datos
        return priceFeedMock.getDataFeedRegistry();
    }

    function getEthAddress() public view returns (address) {
        return ethContractAddress;
    }

    function getBtcAddress() public view returns (address) {
        return btcContractAddress;
    }

    function getLinkAddress() public view returns (address) {
        return linkContractAddress;
    }

    function getUsdtAddress() public view returns (address) {
        return usdtContractAddress;
    }

    function getAdaAddress() public view returns (address) {
        return adaContractAddress;
    }       
    //feedResgistryInterface Address?: 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;

    /*function getPrice(string memory pair) external returns(uint256){
        FeedRegistryInterface feed = priceFeeds[pair];
        require(address(feed) != address(0), "Invalid pair");
        (, int256 answer, , , ) = feed.latestRoundData();

        uint256 price = uint256(answer);
        return price;
    }*/

    //mapping (string => uint256) public prices;
    /*uint256 public BTC_ETHPrice;
    uint256 public ETH_BTCPrice;
    uint256 public LINK_ETHPrice;
    uint256 public ETH_LINKPrice;
    uint256 public USDT_ETHPrice;
    uint256 public ETH_USDTPrice;
    uint256 public ADA_ETHPrice;
    uint256 public ETH_ADAPrice;
*/

    /*FeedRegistryInterface internal immutable priceFeedBTC_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_BTC;
    FeedRegistryInterface internal immutable priceFeedLINK_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_LINK;
    FeedRegistryInterface internal immutable priceFeedUSDT_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_USDT;
    FeedRegistryInterface internal immutable priceFeedADA_ETH;
    FeedRegistryInterface internal immutable priceFeedETH_ADA;*/

    
    /*constructor(
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

    }*/

    function testGetETH_BTCPrice() public view returns(uint256){
        uint256 eth_BTCPrice = priceFeedMock.getDataFeedRegistryEth_Btc();
        return eth_BTCPrice;
    }
    function testGetBTC_ETHPrice() public view returns(uint256){
        uint256 btc_ETHPrice= priceFeedMock.getDataFeedRegistryBtc_Eth();
        return btc_ETHPrice;
    }
    function testGetETH_LINKPrice() public view returns(uint256){
        uint256 eth_LINKPrice = priceFeedMock.getDataFeedRegistryEth_Link();
        return eth_LINKPrice;
    }
    function testGetLINK_ETHPrice() public view returns(uint256){
        uint256 link_ETHPrice = priceFeedMock.getDataFeedRegistryLink_Eth();
        return link_ETHPrice;
    }
    function testGetETH_USDTPrice() public view returns(uint256){
        uint256 eth_USDTPrice = priceFeedMock.getDataFeedRegistryEth_Usdt();
        return eth_USDTPrice;
    }
    function testGetUSDT_ETHPrice() public view returns(uint256){
        uint256 usdt_ETHPrice = priceFeedMock.getDataFeedRegistryUsdt_Eth();
        return usdt_ETHPrice;
    }
    function testGetETH_ADAPrice() public view returns(uint256){
        uint256 eth_ADAPrice = priceFeedMock.getDataFeedRegistryEth_Ada();
        return eth_ADAPrice;
    }
    function testGetADA_ETHPrice() public view returns(uint256){
        uint256 ada_ETHPrice = priceFeedMock.getDataFeedRegistryAda_Eth();
        return ada_ETHPrice;
    }
    /*function getBTC_ETHPrice() public view returns(uint256){
        (, int256 btc_ethPrice, , , ) = registry.latestRoundData(btcContractAddress, ethContractAddress);
        uint256 BTC_ETHPrice = uint256(btc_ethPrice);
        return BTC_ETHPrice;
    }
    function getETH_BTCPrice() public view returns(uint256){
        (, int256 eth_btcPrice, , , ) = registry.latestRoundData(ethContractAddress, btcContractAddress);
        uint256 ETH_BTCPrice= uint256(eth_btcPrice);
        return ETH_BTCPrice;
    }

    function getLINK_ETHPrice() public view returns(uint256){
        (, int256 link_ethPrice, , , ) = registry.latestRoundData(linkContractAddress, ethContractAddress);
        uint256 LINK_ETHPrice = uint256(link_ethPrice);
        return LINK_ETHPrice;
    }
    function getETH_LINKPrice() public view  returns(uint256){
        (, int256 eth_linkPrice, , , ) = registry.latestRoundData(ethContractAddress, linkContractAddress);
        uint256 ETH_LINKPrice = uint256(eth_linkPrice);
        return ETH_LINKPrice;
    }
    function getUSDT_ETHPrice() public view returns(uint256){
        (, int256 usdt_ethPrice, , , ) = registry.latestRoundData(usdtContractAddress, ethContractAddress);
        uint256 USDT_ETHPrice = uint256(usdt_ethPrice);
        return USDT_ETHPrice;
    }
    function getETH_USDTPrice() public view returns(uint256){
        (, int256 eth_usdtPrice, , , ) = registry.latestRoundData(ethContractAddress, usdtContractAddress);
        uint256 ETH_USDTPrice = uint256(eth_usdtPrice);
        return ETH_USDTPrice;
    }
    function getADA_ETHPrice() public view returns(uint256){
        (, int256 ada_ethPrice, , , ) = registry.latestRoundData(adaContractAddress, ethContractAddress);
        uint256 ADA_ETHPrice = uint256(ada_ethPrice);
        return ADA_ETHPrice;
    }
    function getETH_ADAPrice() public view returns(uint256){
        (, int256 eth_adaPrice, , , ) = registry.latestRoundData(ethContractAddress, adaContractAddress);
        uint256 ETH_ADAPrice = uint256(eth_adaPrice);
        return ETH_ADAPrice;
    }*/

}