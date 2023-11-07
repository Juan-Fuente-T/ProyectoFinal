// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// PREGUNTAS
//¿Como acceder a los datos de un mapping del contrato original?
//¿Que es lo que hay que testear, completamente _todo?
//¿Se testean tambien los aToken??

import { Test, console, console2 } from "forge-std/Test.sol";
import { PruebaLendingPool } from "../src/ContratoPrueba.sol";
import { AToken } from "../src/libraries/aToken.sol";
import { ATokenDebt } from "../src/libraries/aTokenDebt.sol";
import { IWETH } from "../src/libraries/IWETH.sol";


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
    IaToken wdai;
    //AToken aToken;
    //ATokenDebt aTokenDebt;

    AToken public aTokenEth;
    AToken public aTokenBtc;
    AToken public aTokenLink;
    AToken public aTokenUsdt;
    AToken public aTokenDai;
    ATokenDebt public aTokenDebtEth;
    ATokenDebt public aTokenDebtBtc;
    ATokenDebt public aTokenDebtLink;
    ATokenDebt public aTokenDebtUsdt;
    ATokenDebt public aTokenDebtDai;
   
    

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
        //wlink = IaToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);//ADRI Prueba VARIANTE
        //wlink = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);// Prueba BTC
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);// Prueba VARIANTE
        wlink = IaToken(0xf531B8F309Be94191af87605CfBf600D71C2cFe0);// OTRA Prueba VARIANTE
        //wusdt = IaToken(0x2CA98D7C8504a1eD69619EEc527B279361c70dca);
        //wusdt = IaToken(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06);// VARIANTE PRUEBA ADRI
        //wusdt = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);// PRUEBA USDT
        wusdt = IaToken(0x74540605Dc99f9cd65A3eA89231fFA727B1049E2);// OTRA PRUEBA USDC
        //wdai = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923);//dai
        wdai = IaToken(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6);//dai PRUEBA DAI


        aTokenEth = new AToken("ReplicaAaveTokenEth", "ATKETH", 18);
        aTokenBtc = new AToken("ReplicaAaveTokenBtc", "ATKBTC", 18);
        aTokenLink = new AToken("ReplicaAaveTokenLink", "ATKLINK", 18);
        aTokenUsdt = new AToken("ReplicaAaveTokenUsdt", "ATKUSDT", 18);
        aTokenDai = new AToken("ReplicaAaveTokenDai", "ATKDAI", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebtEth", "DETH", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebBtc", "DBTC", 18);
        aTokenDebtLink = new ATokenDebt("ReplicaAaveTokenDebtLink", "DLINK", 18);
        aTokenDebtUsdt = new ATokenDebt("ReplicaAaveTokenDebtUsdt", "DUSDT", 18);
        aTokenDebtDai = new ATokenDebt("ReplicaAaveTokenDebtDai", "DDAI", 18);
        
        //address _aToken = 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62;
        //address _aTokenDebt = 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af;

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
        deal(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, alice, 1500 ether);//weth
        //deal(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, alice, 100 ether);//variante weth
        //deal de wbtc
        //deal(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, alice, 100 ether);
        deal(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, alice, 1500 ether);//wbtc
        //deal(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, alice, 100 ether);//wlink
        //deal(0x779877A7B0D9E8603169DdbD7836e478b4624789, alice, 500 ether);//wlink prueba VARIANTE
        deal(0xf531B8F309Be94191af87605CfBf600D71C2cFe0, alice, 1500 ether);//wlink OTRA prueba VARIANTE
        //deal(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, alice, 200 ether);//wlink prueba VARIANTE
        //deal(0x2CA98D7C8504a1eD69619EEc527B279361c70dca, alice, 100 ether);//wusdt
        //deal(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06, alice, 500 ether);//wusdt VARIANTE PRUEBA
        deal(0x74540605Dc99f9cd65A3eA89231fFA727B1049E2, alice, 1500 ether);//wusdt OTRA VARIANTE PRUEBA
        //deal(0xd1f79B76d477F026e8119dF29083e3eF8192f923, alice, 100 ether);//wdai
        deal(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6, alice, 1250 ether);//wdai PRUEBA DAI
        
        vm.startPrank(alice);
        //pruebaLendingPoolTest.setOwner(address(this));    
        //aToken.approve(testPruebaLendingPool, 10 ether);
        
        console.log("Alice's balance antes deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));
        console.log("Alice's balance INTERNO antes deposit: ", alice.balance);

        console.log("Alice's balance despues deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));
        
        console.log("Alice's balance despues withdraw: ", pruebaLendingPoolTest.balanceOf(alice,0));
        //console.log("Tokens balance despues withdraw: ", aToken.userBalance(msg.sender));
        //console.log("Tokens supply despues withdraw: ", aToken.tokenSupply());
        console.log("Supply ETH",pruebaLendingPoolTest.totalSupply(0));
        console.log("Supply BTC",pruebaLendingPoolTest.totalSupply(1));
        console.log("Underly. BTC",pruebaLendingPoolTest.getUnderlying(1));
        console.log("Underly. LINK",pruebaLendingPoolTest.getUnderlying(2));
        console.log("Underly. USDT",pruebaLendingPoolTest.getUnderlying(3));

        weth.approve(address(pruebaLendingPoolTest), 50 ether);
        pruebaLendingPoolTest.deposit(0, 50 ether);
        pruebaLendingPoolTest.withdraw(0, 10 ether);

        weth.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(0, 100 ether);
        pruebaLendingPoolTest.withdraw(0, 10 ether);

        wbtc.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(1, 100 ether);
        pruebaLendingPoolTest.withdraw(1, 10 ether);
        //(pruebaLendingPoolTest.pools[2].underlying).approve(address(pruebaLendingPoolTest), 100 ether);
        wlink.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(2, 100 ether);
        pruebaLendingPoolTest.withdraw(2, 10 ether);
        console.log("SUPPLY_DAI", pruebaLendingPoolTest.totalSupply(2));

        wusdt.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(3, 100 ether);
        pruebaLendingPoolTest.withdraw(3, 10 ether);
        
        wdai.approve(address(pruebaLendingPoolTest), 100 ether);
        pruebaLendingPoolTest.deposit(4, 100 ether);
        pruebaLendingPoolTest.withdraw(4, 10 ether);
        console.log("Supply BTC",pruebaLendingPoolTest.totalSupply(1));

        //console.log("IdBorro1", pruebaLendingPoolTest.getIdBorrow(alice, 1));
       
        console.log("DataFeedETH_USD",pruebaLendingPoolTest.getDataFeed(0));
        console.log("DataFeedBTC_USD",pruebaLendingPoolTest.getDataFeed(1));
        console.log("DataFeedLINK_USD",pruebaLendingPoolTest.getDataFeed(2));
        console.log("DataFeedUSDC_USD",pruebaLendingPoolTest.getDataFeed(3));
        console.log("DataFeedDAI_USD",pruebaLendingPoolTest.getDataFeed(4));

        console.log("Link en Usdc",pruebaLendingPoolTest.getConvertedValue(2, 3));
        console.log("Eth en Btc",pruebaLendingPoolTest.getConvertedValue(0, 1));
        console.log("Btc en Link",pruebaLendingPoolTest.getConvertedValue(1, 2));
        console.log("Btc en Dai",pruebaLendingPoolTest.getConvertedValue(1, 4));
        console.log("Dai en Eth",pruebaLendingPoolTest.getConvertedValue(4, 0));
        console.log("Usdc en Btc",pruebaLendingPoolTest.getConvertedValue(3, 1));
        console.log("Link en Usdc",pruebaLendingPoolTest.getConvertedValue(2, 3));
        console.log("Dai en Btc",pruebaLendingPoolTest.getConvertedValue(4, 1));
        console.log("Usdc en Eth",pruebaLendingPoolTest.getConvertedValue(3, 0));
        console.log("Eth en Link",pruebaLendingPoolTest.getConvertedValue(0, 2));

        pruebaLendingPoolTest.borrow(0, 2, 10 ether);//0
        console.log("LoanCounter",pruebaLendingPoolTest.getLoanCounter());
        console.log("UserDebt", pruebaLendingPoolTest.getUserDebt(0));
        console.log("SUPPLY_DAI", pruebaLendingPoolTest.totalSupply(2));
        //pruebaLendingPoolTest.borrow(0, 2, 10 ether);//0
        pruebaLendingPoolTest.borrow(2, 1, 10 ether);//1
        console.log("LoanCounter",pruebaLendingPoolTest.getLoanCounter());
        console.log("UserDebt", pruebaLendingPoolTest.getUserDebt(1));
        pruebaLendingPoolTest.borrow(1, 3, 10 ether);//2
        console.log("LoanCounter",pruebaLendingPoolTest.getLoanCounter());
        console.log("UserDebt", pruebaLendingPoolTest.getUserDebt(2));
        pruebaLendingPoolTest.borrow(3, 0, 20 ether);//3
        pruebaLendingPoolTest.borrow(4, 0, 20 ether);//4
        pruebaLendingPoolTest.borrow(3, 4, 20 ether);//5
        
       
       /* uint256 debt0 = (pruebaLendingPoolTest.getUserDebt(0));
        console.log("Debt0", debt0);
        weth.approve(address(pruebaLendingPoolTest), debt0);
        pruebaLendingPoolTest.repay(2, 0, debt0, 0);
    
        uint256 debt1 = (pruebaLendingPoolTest.getUserDebt(1));
        console.log("Debt1", debt1);
        wlink.approve(address(pruebaLendingPoolTest), debt1);//link
        pruebaLendingPoolTest.repay(1, 2, debt1, 1);
    
        uint256 debt2 = (pruebaLendingPoolTest.getUserDebt(2));
        console.log("Debt2", debt2);
        wbtc.approve(address(pruebaLendingPoolTest), debt2 );
        pruebaLendingPoolTest.repay(3, 1, debt2 , 2);
    
        uint256 debt3 = (pruebaLendingPoolTest.getUserDebt(3));
        console.log("Debt3", debt3);
        wusdt.approve(address(pruebaLendingPoolTest), debt3);//DAI FALSO
        //pruebaLendingPoolTest.repay(0, 3, debt3 , 3);
         
        uint256 debt4 = pruebaLendingPoolTest.getUserDebt(4);
        console.log("Debt4", debt4);
        wdai.approve(address(pruebaLendingPoolTest), debt4);
        pruebaLendingPoolTest.repay(0, 4, debt4, 4);

        uint256 debt5 = (pruebaLendingPoolTest.getUserDebt(5));
        console.log("Debt5", debt5);
        wusdt.approve(address(pruebaLendingPoolTest), debt5);//DAI FALSO
        pruebaLendingPoolTest.repay(4, 3, debt5, 5);

        console.log("LoanCounter",  pruebaLendingPoolTest.getLoanCounter());
    */
        
        
        
        
        
        /*
        
        console.log("Supply BTC Antes borrow",pruebaLendingPoolTest.totalSupply(1));
        console.log("User collateral 0", pruebaLendingPoolTest.getUserCollateral(0, 1));
        console.log("User debt 0", pruebaLendingPoolTest.getUserDebt(1, 0));

        console.log("Supply BTC Antes borrow Falla",pruebaLendingPoolTest.totalSupply(1));
        console.log("Supply USDT Antes borrow Falla",pruebaLendingPoolTest.totalSupply(3));
        pruebaLendingPoolTest.borrow(0, 2, 5 ether);
        //console.log("AmountCollateral borrow025", pruebaLendingPoolTest.getAmountCollateral());
        //console.log("Amountborrow025", pruebaLendingPoolTest.getAmount());
        
        //pruebaLendingPoolTest.borrow(2, 4, 5 ether);
        //console.log("AmountCollateral borrow245", pruebaLendingPoolTest.getAmountCollateral());
        console.log("Amountborrow245", pruebaLendingPoolTest.getAmount());
        pruebaLendingPoolTest.borrow(1, 3, 10 ether);
        console.log("AmountCollateral borrow1310", pruebaLendingPoolTest.getAmountCollateral());
        console.log("Amountborrow1310", pruebaLendingPoolTest.getAmount());
        //console.log("Borrow0 poolId", pruebaLendingPoolTest.getBorrowPoolId(alice, 0));
        
        //console.log("BorrowEXTTRA poolId", pruebaLendingPoolTest.getBorrowPoolId(alice, 5));//solo hay 5 poolId

        //pruebaLendingPoolTest.borrow(4, 0, 10 ether);
        console.log("Balance 2", pruebaLendingPoolTest.balanceOf(alice,2));
        pruebaLendingPoolTest.borrow(3, 0, 10 ether);
        //pruebaLendingPoolTest.borrow(4, 1, 20 ether);
        //console.log("IdBorrow1", pruebaLendingPoolTest.getIdBorrow(alice, 1));
        //console.log("IdBorrow2", pruebaLendingPoolTest.getIdBorrow(alice, 2));
        
        console.log("User collateral 1 despues borrow", pruebaLendingPoolTest.getUserCollateral(1, 3));
        console.log("User debt 1 despues borrow", pruebaLendingPoolTest.getUserDebt(1, 3));
        //pruebaLendingPoolTest.borrow(3, 4, 5 ether);

        console.log("Supply BTC Antes repay",pruebaLendingPoolTest.totalSupply(1));
        wbtc.approve(address(pruebaLendingPoolTest), 3.75 ether);//BTC FALSO    
        console.log("User collateral 0", pruebaLendingPoolTest.getUserCollateral(0, 2));
        console.log("User debt 0", pruebaLendingPoolTest.getUserDebt(0, 2));
        pruebaLendingPoolTest.repay(2, 0, 3.75 ether, 0);
        console.log("User collateral 0 despues", pruebaLendingPoolTest.getUserCollateral(0, 2));
        console.log("User debt 0 despues", pruebaLendingPoolTest.getUserDebt(0, 2));
        console.log("Supply BTC Despues repay",pruebaLendingPoolTest.totalSupply(1));

        console.log("User collateral 1", pruebaLendingPoolTest.getUserCollateral(1, 0));
        console.log("User debt 1", pruebaLendingPoolTest.getUserDebt(1, 0));
        //pruebaLendingPoolTest.borrow(1, 4, 5 ether);
    
        wdai.approve(address(pruebaLendingPoolTest), 3.75 ether);
        //pruebaLendingPoolTest.repay(4, 1, 3.75 ether, 6);

        wdai.approve(address(pruebaLendingPoolTest), 3.75 ether);
        //pruebaLendingPoolTest.repay(4, 2, 3.75 ether, 1);

        wbtc.approve(address(pruebaLendingPoolTest), 7.5 ether);
        pruebaLendingPoolTest.repay(3, 1, 7.5 ether, 2);
    
        weth.approve(address(pruebaLendingPoolTest), 7.5 ether);
       // pruebaLendingPoolTest.repay(0, 4, 7.5 ether, 3);
    
        weth.approve(address(pruebaLendingPoolTest), 7.5 ether);//BTC FALSO
        pruebaLendingPoolTest.repay(0, 3, 7.5 ether, 4);
    
        wbtc.approve(address(pruebaLendingPoolTest), 15 ether);
        //pruebaLendingPoolTest.repay(1, 4, 7.5 ether, 5);*/
    
    } 
}