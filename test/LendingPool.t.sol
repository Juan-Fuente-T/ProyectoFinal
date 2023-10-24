// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// PREGUNTAS
//¿Como acceder a los datos de un mapping del contrato original?
//¿Que es lo que hay que testear, completamente _todo?
//¿Se testean tambien los aToken??

import { Test, console, console2 } from "forge-std/Test.sol";
import { LendingPool } from "../src/LendingPool - copia.sol";
import { InterestRates } from "../src/InterestRates-copia.sol";
import { PriceOracle } from "../src/PriceOracle-copia.sol";
import { AToken } from "../src/aToken.sol";
import { ATokenDebt } from "../src/aTokenDebt.sol";
import { PriceFeedMock } from "../src/PriceFeedMock.sol";
import { IWETH } from "../src/libraries/IWETH.sol";
import {LoanContract} from "../src/LoanContract.sol";

contract LendingPoolTest is Test {
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
    uint256 sepoliaFork;


        
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
        address _aToken = 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62;
        address _aTokenDebt = 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af;
        //forge create src/AToken.sol:ContractWithNoConstructor

        /*
        address _feedRegistryInterface = priceFeedMock.getPriceFeedRegistryAddress();
        address _ethContractAddress = priceFeedMock.getEthContractAddress();
        address _btcContractAddress = priceFeedMock.getBtcContractAddress();
        address _linkContractAddress = priceFeedMock.getLinkContractAddress();
        address _usdtContractAddress = priceFeedMock.getUsdtContractAddress();
        address _adaContractAddress = priceFeedMock.getAdaContractAddress();
       */

        //mainnetFork = vm.createFork(MAINNET_RPC_URL);
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        //vm.selectFork(mainnetFork);
        vm.selectFork(sepoliaFork);
        priceFeedMock = new PriceFeedMock();
        priceOracle = new PriceOracle(priceFeedMock, _feedRegistryInterface, _ethContractAddress, _btcContractAddress, _linkContractAddress, _usdtContractAddress, _adaContractAddress);
        interestRates = new InterestRates(eth_atr, btc_curve2, priceFeedMock);
        loanContract = new LoanContract(priceOracle, interestRates, lendingPoolTest);
        lendingPoolTest = new LendingPool(priceOracle,interestRates,loanContract);
        //lendingPoolTest.setTokens(_aToken, _aTokenDebt);
    }

    function testLendingPool() public{
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
        vm.deal(alice, 500 ether);
        vm.startPrank(alice);
        uint256 balance = lendingPoolTest.balanceOf(alice,0);
        //console.log("Alice's balance antes deposit: ", balance);

        lendingPoolTest.deposit(0,100);
        lendingPoolTest.deposit(1,100);
        lendingPoolTest.deposit(2,100);
        lendingPoolTest.deposit(3,100);
        lendingPoolTest.deposit(4,100);
      
        //console.log("weth Supply",lendingPoolTest.wETHTotalSupply());
        //console.log("weth user balance",lendingPoolTest.wETHUserBalance(alice));
        //vm.stopPrank;
        //vm.startPrank(wbtcAddress);
        //lendingPoolTest.deposit(1, 250);
        console.log("Alice's balance antes PROBLEMA: ", lendingPoolTest.balanceOf(alice, 0));
        assertEq(175000000000000000000, lendingPoolTest.balanceOf(alice, 0));
        assertEq(275000000000000000000, lendingPoolTest.totalSupply(0));
        
        uint256 assetTotalSupply0 = lendingPoolTest.totalSupply(0);
        uint256 assetTotalSupply1 = lendingPoolTest.totalSupply(1);
        uint256 assetTotalSupply2 = lendingPoolTest.totalSupply(2);
        uint256 assetTotalSupply3 = lendingPoolTest.totalSupply(3);
        uint256 assetTotalSupply4 = lendingPoolTest.totalSupply(4);
        assertEq(275000000000000000000, lendingPoolTest.totalSupply(0));
        
        console.log(assetTotalSupply1, assetTotalSupply2, assetTotalSupply3, assetTotalSupply4);
        uint256 amountAToken = lendingPoolTest.getAmountAToken();
        console.log("amountAToken", amountAToken);
        uint256 amount = lendingPoolTest.getAmount();
        console.log("amount", amount);

        assertEq(175000000000000000000, lendingPoolTest.balanceOf(alice, 0));

        //lendingPoolTest.withdraw(0, 15);
        //lendingPoolTest.withdraw(0, 10);

        //user, pooid, catidadTotalSupply, cantidadUser
        lendingPoolTest.setTotalSupplyAndOthers(alice, 1, 0, 10);
        console.log("Fondos nuevos Alice BTC:", lendingPoolTest.balanceOf(alice, 1));
        lendingPoolTest.setTotalSupplyAndOthers(alice, 2, 0, 10);
        console.log("Fondos nuevos Alice Link:", lendingPoolTest.balanceOf(alice, 2));
        lendingPoolTest.setTotalSupplyAndOthers(alice, 3, 0, 10);
        console.log("Fondos nuevos Alice Usdt:", lendingPoolTest.balanceOf(alice, 3));
        lendingPoolTest.setTotalSupplyAndOthers(alice, 4, 0, 10);
        console.log("Fondos nuevos Alice ADA:", lendingPoolTest.balanceOf(alice, 4));
        console.log("Nuevos withdraw");
        lendingPoolTest.withdraw(1, 10);
        lendingPoolTest.withdraw(2, 10);
        lendingPoolTest.withdraw(3, 10);
        lendingPoolTest.withdraw(4, 9);
        console.log("Fin nuevos withdraw");

        assertEq(150000000000000000000, lendingPoolTest.balanceOf(alice, 0));
        assertEq(250000000000000000000, lendingPoolTest.totalSupply(0));
        //console.log("totalSupply ETH despues withdraw:", lendingPoolTest.totalSupply(0));
        
        console.log("totalSupply BTC ANTES borrow:", lendingPoolTest.totalSupply(1));
        console.log("totalSupply ADA ANTES borrow:", lendingPoolTest.totalSupply(4));
        //(alice,0,1,5) pool donde coger collateral, pool de donde se quiere quitar, amount
        lendingPoolTest.borrow(alice, 1, 0, 6);
        lendingPoolTest.borrow(alice, 4, 0, 7);

        console.log("AmountCollateral borrow: ", lendingPoolTest.getAmountCollateral());
        
        assertEq(137000000000000000000, lendingPoolTest.balanceOf(alice, 0));
        assertEq(250000000000000000000, lendingPoolTest.totalSupply(0));
        assertEq(6000000000000000000, lendingPoolTest.getCollateral(alice, 1));
        assertEq(7000000000000000000, lendingPoolTest.getCollateral(alice, 4));
        assertEq(4500000000000000000, lendingPoolTest.getDebt(alice, 1));
        assertEq(5250000000000000000, lendingPoolTest.getDebt(alice, 4));


        console.log("Alice's balance despues borrow: ", lendingPoolTest.balanceOf(alice, 0));
        console.log("Alice's colateral para BTC despues borrow: ", lendingPoolTest.getCollateral(alice, 1));
        console.log("Alice's colateral para ADA despues borrow: ", lendingPoolTest.getCollateral(alice, 4));
        console.log("AmountCollateral: ", lendingPoolTest.getAmountCollateral());
        console.log("Alice's deuda BTC despues borrow: ", lendingPoolTest.getDebt(alice, 1));
        console.log("Alice's deuda ADA despues borrow: ", lendingPoolTest.getDebt(alice, 4));
        console.log("totalSupply ETH despues borrow:", lendingPoolTest.totalSupply(0));
        console.log("totalSupply BTC despues borrow:", lendingPoolTest.totalSupply(1));
        console.log("totalSupply ADA despues borrow:", lendingPoolTest.totalSupply(4));

        lendingPoolTest.setTotalSupplyAndOthers(alice,1, 0, 100);
        lendingPoolTest.setTotalSupplyAndOthers(alice,4, 0, 100);
        //orden de parametros en BORROW, address, pool de donde se toma el borrow, balance de donde se coge el colateral, amount
        lendingPoolTest.borrow(alice, 0, 1, 3);
        lendingPoolTest.borrow(alice, 0, 4, 9);
        lendingPoolTest.borrow(alice, 2, 1, 1);
        lendingPoolTest.borrow(alice, 4, 0, 11);

        //console.log("Alice's balance despues borrow: ", lendingPoolTest.balanceOf(alice, 0));
        //assertEq(250000000000000000000, lendingPoolTest.totalSupply(0));
        console.log("Alice's colateral para BTC despues borrow: ", lendingPoolTest.getCollateral(alice, 1));
        console.log("Alice's colateral para ADA despues borrow: ", lendingPoolTest.getCollateral(alice, 4));

        //assertEq(, lendingPoolTest.totalSupply(0));
        //assertEq(", lendingPoolTest.totalSupply(1));
        //assertEq(, lendingPoolTest.totalSupply(4));
        console.log("Alice's deuda ETH despues borrow2: ", lendingPoolTest.getDebt(alice, 0));
        console.log("Alice's deuda ADA despues borrow2: ", lendingPoolTest.getDebt(alice, 4));
        console.log("totalSupply ETH despues borrow2:", lendingPoolTest.totalSupply(0));
        console.log("totalSupply BTC despues borrow2:", lendingPoolTest.totalSupply(1));
        console.log("totalSupply ADA despues borrow2:", lendingPoolTest.totalSupply(4));
        console.log("totalSupply USDT despues borrow2:", lendingPoolTest.totalSupply(3));
        console.log("totalSupply LINK despues borrow2:", lendingPoolTest.totalSupply(2));
        console.log("Balance Alice BTC despues borrow2:", lendingPoolTest.balanceOf(alice, 1));
        console.log("Balance Alice LINK despues borrow2:", lendingPoolTest.balanceOf(alice, 2));
        console.log("totalSupply USDT despues borrow2:", lendingPoolTest.balanceOf(alice, 3));
        console.log("Balance ALICE ADA despues borrow2:", lendingPoolTest.balanceOf(alice, 4));
        console.log("Alice's deuda LINK despues borrow2: ", lendingPoolTest.getDebt(alice, 2));
        console.log("Alice's colateral LINK despues borrow2: ", lendingPoolTest.getCollateral(alice, 2));
        console.log("Alice's deuda usdt despues borrow2: ", lendingPoolTest.getDebt(alice, 3));
        console.log("Alice's colateral usdt despues borrow2: ", lendingPoolTest.getCollateral(alice, 3));
        console.log("PruebaUpdatePrincipalETH", lendingPoolTest.updatePrincipal(0));
        console.log("PruebaUpdateBorrow ETH", lendingPoolTest.updateBorrow(0));
    }
}