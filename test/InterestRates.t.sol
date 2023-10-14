// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console, console2} from "forge-std/Test.sol";
import {InterestRates} from "../src/InterestRates-copia.sol";
import {PriceFeedMock} from "../src/PriceFeedMock.sol";
contract InterestRatesTest is Test {
    //string MAINNET_RPC_URL = vm.envString(MAINNET_RPC_URL);
    InterestRates interestRatesTest;
    PriceFeedMock priceFeedMock;
    string MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3';


    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29
    //address eth_atr = 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29;
    address eth_atr = makeAddr("eth_atr");
    //address btc_curve2 = 0x39545d0c11CD62d787bB971B6a802150e1f54D8f;
    address btc_curve2 = makeAddr("btc_cruve2");
    uint256 mainnetFork;

    function setUp() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        priceFeedMock = new PriceFeedMock();
        interestRatesTest = new InterestRates(eth_atr, btc_curve2, priceFeedMock);
       
    }
/*function testInterestRates (address _address)public pure returns (bool){
            bytes memory addressBytes = abi.encodePacked(_address);
    bytes memory pattern = hex"(0x)?[0-9a-fA-F]{40}";

    if (addressBytes.length != 20) {
        return false;
    }

    bytes memory substring = new bytes(40);
    for (uint i = 0; i < 40; i++) {
        substring[i] = addressBytes[i+12];
    }

    bytes memory result = new bytes(42);
    result[0] = '0';
    result[1] = 'x';
    for (uint i = 0; i < 40; i++) {
        result[i+2] = substring[i];
    }

    return (keccak256(result) == keccak256(pattern));

    console2.logBytes32(checksum);
        
    }*/

    function testCanSelectFork() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
        
    }
    function testInterestRates() public{
    
        //uint256 interestRate = interestRatesTest.getInterestRate();
        uint256 interestRate = interestRatesTest.getDataFromChainlink();
        assertEq(100, interestRate);
        console.log(interestRate);
    
        //uint256 interestBorrow = interestRatesTest.getInterestBorrow();
        //uint256 interestBorrow = priceFeedMock.getData()
        uint256 interestBorrow = interestRatesTest.getDataFromChainlink();
        assertEq(100, interestBorrow);
        console.log(interestBorrow);
    }
        /*assertRevert(
                function() { interestRatesTest.getInterestBorrow(); },
                "Error message from require statement"
            );*/
        
}