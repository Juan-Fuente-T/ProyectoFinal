// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


// PREGUNTAS
//¿Como acceder a los datos de un mapping del contrato original?
//¿Que es lo que hay que testear, completamente _todo?
//¿Se testean tambien los aToken??

import { Test, console, console2 } from "forge-std/Test.sol";
import { PruebaLendingPool } from "../src/ContratoPrueba.sol";
import { AToken } from "../src/aToken.sol";
import { ATokenDebt } from "../src/aTokenDebt.sol";
//import { PriceFeedMock } from "../src/PriceFeedMock.sol";
import { IWETH } from "../src/libraries/IWETH.sol";
//import {LoanContract} from "../src/LoanContract.sol";
import { ATokenEth } from "../src/libraries/wETH.sol";
import { ATokenBtc } from "../src/libraries/wBTC.sol";
import { ATokenLink } from "../src/libraries/wLINK.sol";
import { ATokenUsdt } from "../src/libraries/wUSDT.sol";
import { ATokenAda } from "../src/libraries/wADA.sol";
import { ATokenDebtEth } from "../src/libraries/wETHDebt.sol";
import { ATokenDebtBtc } from "../src/libraries/wBTCDebt.sol";
import { ATokenDebtLink } from "../src/libraries/wLINKDebt.sol";
import { ATokenDebtUsdt } from "../src/libraries/wUSDTDebt.sol";
import { ATokenDebtAda } from "../src/libraries/wADADebt.sol";





interface IaToken{
    function mint(address user, uint256 amount) external; 
    function burn(address user, uint256 amount) external;
    function _burn(address account, uint256 amount) external;
    function _mint(address account, uint256 amount) external;
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function userBalance(address user) external returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool); 
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

contract PruebaLendingPoolTest is Test {
    PruebaLendingPool pruebaLendingPoolTest;
    IaToken weth;
    IaToken wbtc;
    IaToken wlink;
    IaToken wusdt;
    IaToken wada;
    AToken aToken;
    ATokenDebt aTokenDebt;

    ATokenEth public aTokenEth;
    ATokenBtc public aTokenBtc;
    ATokenLink public aTokenLink;
    ATokenUsdt public aTokenUsdt;
    ATokenAda public aTokenAda;
    ATokenDebtEth public aTokenDebtEth;
    ATokenDebtBtc public aTokenDebtBtc;
    ATokenDebtLink public aTokenDebtLink;
    ATokenDebtUsdt public aTokenDebtUsdt;
    ATokenDebtAda public aTokenDebtAda;
   
    

    string MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3';
    string SEPOLIA_RPC_URL = 'https://eth-sepolia.g.alchemy.com/v2/QF_rlvr4V0ZORimK7ysBA4mJvl0Bk47c';
   
    uint256 mainnetFork;
    uint256 sepoliaFork;


        
    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    function setUp() public {
        //ddress owner = address(PruebaLendingPoolTest);
        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);//funciona bien ? weth?
        //weth = IaToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//variante weth
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        wbtc = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);
        wlink = IaToken(0xcE4cE12Cf2c4BDF213DCaA1ACA99ECA9Cd4d7F14);// Prueba VARIANTE
        //wusdt = IaToken(0x2CA98D7C8504a1eD69619EEc527B279361c70dca);
        wusdt = IaToken(0x55Ef41E13CF703eA5929b1Ce117D263766519DDe);//VARIANTE PRUEBA
        //wada = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923);
        wada = IaToken(0x5C1A2a4808Fd0Db90eBA797254C5ef82cbfc4b8D);//ada PRUEBA DAI

        aTokenEth = new ATokenEth();
        aTokenBtc = new ATokenBtc();
        aTokenLink = new ATokenLink();
        aTokenUsdt = new ATokenUsdt();
        aTokenAda = new ATokenAda();
        aTokenDebtEth = new ATokenDebtEth();
        aTokenDebtEth = new ATokenDebtEth();
        aTokenDebtLink = new ATokenDebtLink();
        aTokenDebtUsdt = new ATokenDebtUsdt();
        aTokenDebtAda = new ATokenDebtAda();
        

        address _aToken = 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62;
        address _aTokenDebt = 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af;

        //mainnetFork = vm.createFork(MAINNET_RPC_URL);
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        //vm.selectFork(mainnetFork);
        vm.selectFork(sepoliaFork);
        pruebaLendingPoolTest = new PruebaLendingPool();
        pruebaLendingPoolTest.setOwner(address(this));    
        //lendingPoolTest.setTokens(_aToken, _aTokenDebt);
    }

    function testPruebaLendingPool() public{

        // Obtener la dirección del contrato WBTC en Foundry
        //address wbtcAddress = getAddress("WBTC");
        // Transferir 10 WBTC al contrato LendingPool
        //vm.deal(wbtcAddress, lendingPoolTest, 10);

        address alice = makeAddr("alice");
        //vm.deal(alice, 500 ether);
        //deal de weth
        deal(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, alice, 100 ether);//weth
        //deal(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, alice, 100 ether);//variante weth
        //deal de wbtc
        //deal(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, alice, 100 ether);
        deal(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, alice, 100 ether);//wbtc
        //deal(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, alice, 100 ether);//wlink
        deal(0xcE4cE12Cf2c4BDF213DCaA1ACA99ECA9Cd4d7F14, alice, 100 ether);//wlink prueba VARIANTE
        //deal(0x2CA98D7C8504a1eD69619EEc527B279361c70dca, alice, 100 ether);//wusdt
        deal(0x55Ef41E13CF703eA5929b1Ce117D263766519DDe, alice, 100 ether);//wusdt VARIANTE PRUEBA
        //deal(0xd1f79B76d477F026e8119dF29083e3eF8192f923, alice, 100 ether);//wada
        deal(0x5C1A2a4808Fd0Db90eBA797254C5ef82cbfc4b8D, alice, 100 ether);//wada PRUEBA DAI
       
        vm.startPrank(alice);
        //pruebaLendingPoolTest.setOwner(address(this));    
        //aToken.approve(testPruebaLendingPool, 10 ether);
        console.log("Antes approve");
        weth.approve(address(pruebaLendingPoolTest), 35 ether);
        pruebaLendingPoolTest.deposit(0, 35 ether);
        console.log("Despues approve");

        console.log("Alice's balance antes deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));
        console.log("Alice's balance INTERNO antes deposit: ", alice.balance);

        //weth.approve(address(pruebaLendingPoolTest), 10 ether);
        console.log("Alice's balance despues deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));
        pruebaLendingPoolTest.withdraw(0, 10 ether);
        console.log("Alice's balance despues withdraw: ", pruebaLendingPoolTest.balanceOf(alice,0));
        //console.log("Tokens balance depues withdraw: ", aToken.userBalance(msg.sender));
        //console.log("Tokens supply depues withdraw: ", aToken.tokenSupply());
        //weth.approve(address(lendingPoolTest), 175 ether);
        //lendingPoolTest.deposit(0,175 ether);
        console.log("Supply ETH",pruebaLendingPoolTest.totalSupply(0));
        console.log("Supply BTC",pruebaLendingPoolTest.totalSupply(1));

        wbtc.approve(address(pruebaLendingPoolTest), 95 ether);
        pruebaLendingPoolTest.deposit(1, 95 ether);
        pruebaLendingPoolTest.withdraw(1, 15 ether);
        wlink.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(2, 100 ether);
        wusdt.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(3, 100 ether);
        wada.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(4, 100 ether);
        console.log("Supply BTC",pruebaLendingPoolTest.totalSupply(1));

        console.log("IdBorro0", pruebaLendingPoolTest.getIdBorrow(alice, 0));
        console.log("IdBorro1", pruebaLendingPoolTest.getIdBorrow(alice, 1));
        console.log("IdBorro2", pruebaLendingPoolTest.getIdBorrow(alice, 2));
        console.log("IdBorro3", pruebaLendingPoolTest.getIdBorrow(alice, 3));
        console.log("IdBorro4", pruebaLendingPoolTest.getIdBorrow(alice, 4));

        console.log("Supply BTC Antes borrow",pruebaLendingPoolTest.totalSupply(1));
        console.log("User collateral 0", pruebaLendingPoolTest.getUserCollateral(alice, 0));
        console.log("User debt 0", pruebaLendingPoolTest.getUserDebt(alice, 0));
        pruebaLendingPoolTest.borrow(1, 4, 5 ether);
        console.log("IdBorro4", pruebaLendingPoolTest.getIdBorrow(alice, 4));

        console.log("Borrow1", pruebaLendingPoolTest.getBorrowPoolId(alice, 1));
        console.log("Supply BTC Antes borrow Falla",pruebaLendingPoolTest.totalSupply(1));
        console.log("Supply USDT Antes borrow Falla",pruebaLendingPoolTest.totalSupply(3));
        pruebaLendingPoolTest.borrow(0, 2, 5 ether);
        console.log("AmountCollateral", pruebaLendingPoolTest.getAmountCollateral());
        console.log("Amount", pruebaLendingPoolTest.getAmount());
        
        pruebaLendingPoolTest.borrow(2, 4, 5 ether);
        pruebaLendingPoolTest.borrow(1, 3, 10 ether);
        console.log("Borrow0", pruebaLendingPoolTest.getBorrowPoolId(alice, 0));
        console.log("Borrow1", pruebaLendingPoolTest.getBorrowPoolId(alice, 1));
        console.log("Borrow2", pruebaLendingPoolTest.getBorrowPoolId(alice, 2));
        console.log("Borrow3", pruebaLendingPoolTest.getBorrowPoolId(alice, 3));
        console.log("Borrow4", pruebaLendingPoolTest.getBorrowPoolId(alice, 4));

        pruebaLendingPoolTest.borrow(4, 0, 10 ether);
        console.log("Balance 2", pruebaLendingPoolTest.balanceOf(alice,2));
        pruebaLendingPoolTest.borrow(3, 0, 10 ether);
        console.log("IdBorrow1", pruebaLendingPoolTest.getIdBorrow(alice, 1));
        console.log("IdBorrow2", pruebaLendingPoolTest.getIdBorrow(alice, 2));
        
        console.log("User collateral 1 despues borrow", pruebaLendingPoolTest.getUserCollateral(alice, 1));
        console.log("User debt 1 despues borrow", pruebaLendingPoolTest.getUserDebt(alice, 1));
        //pruebaLendingPoolTest.borrow(3, 4, 5 ether);

        console.log("Supply BTC Antes repay",pruebaLendingPoolTest.totalSupply(1));
        //wbtc.approve(address(pruebaLendingPoolTest), 3.75 ether);
        console.log("User collateral 0", pruebaLendingPoolTest.getUserCollateral(alice, 0));
        console.log("User debt 0", pruebaLendingPoolTest.getUserDebt(alice, 0));
        //pruebaLendingPoolTest.repay(1, 3.75 ether);
        console.log("User collateral 0 despues", pruebaLendingPoolTest.getUserCollateral(alice, 0));
        console.log("User debt 0 despues", pruebaLendingPoolTest.getUserDebt(alice, 0));
        console.log("Supply BTC Despues repay",pruebaLendingPoolTest.totalSupply(1));

        console.log("User collateral 1", pruebaLendingPoolTest.getUserCollateral(alice, 1));
        console.log("User debt 1", pruebaLendingPoolTest.getUserDebt(alice, 1));
    
        wada.approve(address(pruebaLendingPoolTest), 3.75 ether);
        //pruebaLendingPoolTest.repay(1, 3.75 ether);

        wlink.approve(address(pruebaLendingPoolTest), 3.75 ether);
        pruebaLendingPoolTest.repay(0, 3.75 ether);

        wada.approve(address(pruebaLendingPoolTest), 3.75 ether);
        pruebaLendingPoolTest.repay(2, 3.75 ether);
    
        wusdt.approve(address(pruebaLendingPoolTest), 7.5 ether);
        pruebaLendingPoolTest.repay(1, 7.5 ether);
    
        weth.approve(address(pruebaLendingPoolTest), 7.5 ether);
        pruebaLendingPoolTest.repay(4, 7.5 ether);
    
        weth.approve(address(pruebaLendingPoolTest), 7.5 ether);
        pruebaLendingPoolTest.repay(3, 7.5 ether);
    
    } 
}