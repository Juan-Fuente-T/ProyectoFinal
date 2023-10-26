// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// PREGUNTAS
//¿Como acceder a los datos de un mapping del contrato original?
//¿Que es lo que hay que testear, completamente _todo?
//¿Se testean tambien los aToken??

import { Test, console, console2 } from "forge-std/Test.sol";
import { LendingPool } from "../src/LendingPool-copia.sol";
import { InterestRates } from "../src/InterestRates-copia.sol";
import { PriceOracle } from "../src/PriceOracle-copia.sol";
import { AToken } from "../src/aToken.sol";
import { ATokenDebt } from "../src/aTokenDebt.sol";
import { PriceFeedMock } from "../src/PriceFeedMock.sol";
import { IWETH } from "../src/libraries/IWETH.sol";
import {LoanContract} from "../src/LoanContract.sol";

contract LoanContractTest is Test {
    IWETH weth;
    AToken aToken;
    ATokenDebt aTokenDebt;
    PriceFeedMock priceFeedMock;
    InterestRates interestRates;
    PriceOracle priceOracle;
    LoanContract loanContract;
    LendingPool lendingPoolTest;
    

    string MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3';
    string SEPOLIA_RPC_URL = 'https://eth-sepolia.g.alchemy.com/v2/QF_rlvr4V0ZORimK7ysBA4mJvl0Bk47c';
    uint256 mainnetFork;


        
    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    function setUp() public {
        address owner = makeAddr("owner");
        address eth_atr = makeAddr("eth_atr");
        address btc_curve2 = makeAddr("btc_cruve2");
        address _feedRegistryInterface = makeAddr("_feedRegistryInterface");
        address _ethContractAddress = makeAddr("_ethContractAddress"); 
        address _btcContractAddress = makeAddr("_btcContractAddress"); 
        address _linkContractAddress = makeAddr("_linkContractAddress"); 
        address _usdtContractAddress = makeAddr("_usdtContractAddress"); 
        address _adaContractAddress = makeAddr("_adaContractAddress"); 
        /*
        address _feedRegistryInterface = priceFeedMock.getPriceFeedRegistryAddress();
        address _ethContractAddress = priceFeedMock.getEthContractAddress();
        address _btcContractAddress = priceFeedMock.getBtcContractAddress();
        address _linkContractAddress = priceFeedMock.getLinkContractAddress();
        address _usdtContractAddress = priceFeedMock.getUsdtContractAddress();
        address _adaContractAddress = priceFeedMock.getAdaContractAddress();
       */

        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        priceFeedMock = new PriceFeedMock();
        priceOracle = new PriceOracle(priceFeedMock, _feedRegistryInterface, _ethContractAddress, _btcContractAddress, _linkContractAddress, _usdtContractAddress, _adaContractAddress);
        interestRates = new InterestRates(eth_atr, btc_curve2, priceFeedMock);
        loanContract = new LoanContract(priceOracle, interestRates, lendingPoolTest);
        //lendingPoolTest = new LendingPool(priceOracle,interestRates,loanContract);
        lendingPoolTest = new LendingPool();
    }

    function testLoanContract() public{
        //assertEq(100, lendingPoolTest.assets[0].totalSupply);
        /*console.log(assets[0].totalSupply());
        assertEq(100, assets[1]);
        console.log(assets[1]);
        assertEq(1000, assets[2]);
        console.log(assets[2]);
        assertEq(10000, assets[3]);
        console.log(assets[3]);
        assertEq(1000, assets[4]);
        console.log(assets[4]);*/

        // Obtener la dirección del contrato WBTC en Foundry
        //address wbtcAddress = getAddress("WBTC");
        // Transferir 10 WBTC al contrato LendingPool
        //vm.deal(wbtcAddress, lendingPoolTest, 10);

        address alice = makeAddr("alice");
        vm.deal(alice, 200 ether);
        vm.startPrank(alice);
        uint256 balance = lendingPoolTest.balanceOf(alice,0);
        console.log("Alice's balance antes deposit: ", balance);
        lendingPoolTest.deposit(0, 175);

        /*console.log("Alice's balance despues deposit: ", lendingPoolTest.balanceOf(alice, 0));
        assertEq(275000000000000000000, lendingPoolTest.totalSupply(0));
        assertEq(175000000000000000000, lendingPoolTest.balanceOf(alice, 0));
        console.log("Balance cuenta alice", alice.balance);
        uint256 assetTotalSupply0 = lendingPoolTest.totalSupply(0);
        uint256 assetTotalSupply1 = lendingPoolTest.totalSupply(1);
        uint256 assetTotalSupply2 = lendingPoolTest.totalSupply(2);
        uint256 assetTotalSupply3 = lendingPoolTest.totalSupply(3);
        uint256 assetTotalSupply4 = lendingPoolTest.totalSupply(4);
        console.log("totalSupply ETH despues deposit:", assetTotalSupply0);
        console.log(assetTotalSupply1, assetTotalSupply2, assetTotalSupply3, assetTotalSupply4);
        uint256 amountAToken = lendingPoolTest.getAmountAToken();
        console.log("amountAToken", amountAToken);
        uint256 amount = lendingPoolTest.getAmount();
        console.log("amount", amount);*/


        lendingPoolTest.withdraw(0, 25);

        /*
        balance = lendingPoolTest.balanceOf(alice, 0);
        console.log("Alice's balance despues withdraw: ", balance);
        assertEq(250000000000000000000, lendingPoolTest.totalSupply(0));
        assertEq(150000000000000000000, lendingPoolTest.balanceOf(alice, 0));
        console.log("totalSupply ETH despues withdraw:", lendingPoolTest.totalSupply(0));
        */

        //(1,5,0) pool donde tomar prestado, amount, balance de donde hacer colateral
        lendingPoolTest.borrow(alice, 0, 0, 5);
        //lendingPoolTest.borrow(alice, 0, 1, 5);

        console.log("Alice's balance despues borrow: ", lendingPoolTest.balanceOf(alice, 0));
        console.log("Alice's colateral despues borrow: ", lendingPoolTest.getCollateral(alice, 0));
        console.log("AmountCollateral: ", lendingPoolTest.getAmountCollateral());
        console.log("Alice's deuda despues borrow: ", lendingPoolTest.getDebt(alice, 0));
        //console.log("Alice's deuda despues borrow: ", lendingPoolTest.getDebt(alice));
        console.log("totalSupply ETH despues borrow:", lendingPoolTest.totalSupply(0));
        console.log("totalSupply BTC despues borrow:", lendingPoolTest.totalSupply(1));
        
    }
}
      