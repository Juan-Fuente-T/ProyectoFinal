// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// PREGUNTAS
//¿Como acceder a los datos de un mapping del contrato original?
//¿Que es lo que hay que testear, completamente _todo?
//¿Se testean tambien los aToken??

import {Test, console, console2} from "forge-std/Test.sol";
import {LendingPool} from "../src/LendingPool.sol";
import {AToken} from "../src/libraries/aToken.sol";
import {ATokenDebt} from "../src/libraries/aTokenDebt.sol";
import {IWETH} from "../src/libraries/IWETH.sol";

interface IaToken {
    function mint(address user, uint256 amount) external;

    function burn(address user, uint256 amount) external;

    function _burn(address account, uint256 amount) external;

    function _mint(address account, uint256 amount) external;

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

contract LendingPool2Test is Test {
    LendingPool lendingPoolTest;
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

    string MAINNET_RPC_URL =
        "https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3";
    string SEPOLIA_RPC_URL =
        "https://eth-sepolia.g.alchemy.com/v2/QF_rlvr4V0ZORimK7ysBA4mJvl0Bk47c";

    uint256 mainnetFork;
    uint256 sepoliaFork;

    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    function setUp() public {
        //ddress owner = address(PruebaLendingPoolTest);
        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9); //funciona bien ? weth?
        //weth = IaToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//variante weth
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        wbtc = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);
        //wlink = IaToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);//ADRI Prueba VARIANTE
        //wlink = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);// Prueba BTC
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);// Prueba VARIANTE
        wlink = IaToken(0xf531B8F309Be94191af87605CfBf600D71C2cFe0); // OTRA Prueba VARIANTE
        //wusdt = IaToken(0x2CA98D7C8504a1eD69619EEc527B279361c70dca);
        //wusdt = IaToken(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06);// VARIANTE PRUEBA ADRI
        //wusdt = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);// PRUEBA USDT
        wusdt = IaToken(0x74540605Dc99f9cd65A3eA89231fFA727B1049E2); // OTRA PRUEBA USDC
        //wdai = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923);//dai
        wdai = IaToken(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6); //dai PRUEBA DAI

        aTokenEth = new AToken("ReplicaAaveTokenEth", "ATKETH", 18);
        aTokenBtc = new AToken("ReplicaAaveTokenBtc", "ATKBTC", 18);
        aTokenLink = new AToken("ReplicaAaveTokenLink", "ATKLINK", 18);
        aTokenUsdt = new AToken("ReplicaAaveTokenUsdt", "ATKUSDT", 18);
        aTokenDai = new AToken("ReplicaAaveTokenDai", "ATKDAI", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebtEth", "DETH", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebBtc", "DBTC", 18);
        aTokenDebtLink = new ATokenDebt(
            "ReplicaAaveTokenDebtLink",
            "DLINK",
            18
        );
        aTokenDebtUsdt = new ATokenDebt(
            "ReplicaAaveTokenDebtUsdt",
            "DUSDT",
            18
        );
        aTokenDebtDai = new ATokenDebt("ReplicaAaveTokenDebtDai", "DDAI", 18);

        //address _aToken = 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62;
        //address _aTokenDebt = 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af;

        //mainnetFork = vm.createFork(MAINNET_RPC_URL);
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        //vm.selectFork(mainnetFork);
        vm.selectFork(sepoliaFork);
        lendingPoolTest = new LendingPool();
        lendingPoolTest.setOwner(address(this));
        //lendingPoolTest.setTokens(_aToken, _aTokenDebt);
    }

    function testLendingPool2() public {
        // Obtener la dirección del contrato WBTC en Foundry
        //address wbtcAddress = getAddress("WBTC");
        // Transferir 10 WBTC al contrato LendingPool
        //vm.deal(wbtcAddress, lendingPoolTest, 10);

        address alice = makeAddr("alice");
        //vm.deal(alice, 500 ether);
        //deal de weth
        deal(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, alice, 100000 ether); //weth
        //deal(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, alice, 100 ether);//variante weth
        //deal de wbtc
        //deal(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, alice, 100 ether);
        deal(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, alice, 100000 ether); //wbtc
        //deal(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, alice, 100 ether);//wlink
        //deal(0x779877A7B0D9E8603169DdbD7836e478b4624789, alice, 500 ether);//wlink prueba VARIANTE
        deal(0xf531B8F309Be94191af87605CfBf600D71C2cFe0, alice, 100000 ether); //wlink OTRA prueba VARIANTE
        //deal(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, alice, 200 ether);//wlink prueba VARIANTE
        //deal(0x2CA98D7C8504a1eD69619EEc527B279361c70dca, alice, 100 ether);//wusdt
        //deal(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06, alice, 500 ether);//wusdt VARIANTE PRUEBA
        deal(0x74540605Dc99f9cd65A3eA89231fFA727B1049E2, alice, 100000 ether); //wusdt OTRA VARIANTE PRUEBA
        //deal(0xd1f79B76d477F026e8119dF29083e3eF8192f923, alice, 100 ether);//wdai
        deal(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6, alice, 100000 ether); //wdai PRUEBA DAI

        vm.startPrank(alice);
        //lendingPoolTest.setOwner(address(this));
        //aToken.approve(testPruebaLendingPool, 10 ether);

        console.log(
            "Alice's balance antes deposit: ",
            lendingPoolTest.balanceOf(alice, 0)
        );
        console.log("Alice's balance INTERNO antes deposit: ", alice.balance);

        console.log(
            "Alice's balance despues deposit: ",
            lendingPoolTest.balanceOf(alice, 0)
        );

        console.log(
            "Alice's balance despues withdraw: ",
            lendingPoolTest.balanceOf(alice, 0)
        );
        //console.log("Tokens balance despues withdraw: ", aToken.userBalance(msg.sender));
        //console.log("Tokens supply despues withdraw: ", aToken.tokenSupply());
        console.log("Supply ETH", lendingPoolTest.totalSupply(0));
        console.log("Supply BTC", lendingPoolTest.totalSupply(1));
        console.log("Supply LINK", lendingPoolTest.totalSupply(2));
        console.log("Underlying. BTC", lendingPoolTest.getUnderlying(1));
        console.log("Underlying. LINK", lendingPoolTest.getUnderlying(2));
        console.log("Underlying. USDT", lendingPoolTest.getUnderlying(3));

        weth.approve(address(lendingPoolTest), 50 ether);
        lendingPoolTest.deposit(0, 50 ether);
        lendingPoolTest.withdraw(0, 10 ether);

        weth.approve(address(lendingPoolTest), 100 ether);

        lendingPoolTest.deposit(0, 100 ether);
        lendingPoolTest.withdraw(0, 10 ether);

        wbtc.approve(address(lendingPoolTest), 100 ether);
        lendingPoolTest.deposit(1, 100 ether);
        lendingPoolTest.withdraw(1, 10 ether);
        //(lendingPoolTest.pools[2].underlying).approve(address(lendingPoolTest), 100 ether);
        wlink.approve(address(lendingPoolTest), 10000 ether);
        lendingPoolTest.deposit(2, 10000 ether);
        lendingPoolTest.withdraw(2, 10 ether);
        console.log("SUPPLY_LINK", lendingPoolTest.totalSupply(2));

        wusdt.approve(address(lendingPoolTest), 100000 ether);
        lendingPoolTest.deposit(3, 100000 ether);
        lendingPoolTest.withdraw(3, 10 ether);

        wdai.approve(address(lendingPoolTest), 7777 ether);
        lendingPoolTest.deposit(4, 7777 ether);
        lendingPoolTest.withdraw(4, 10 ether);
        console.log("Supply BTC", lendingPoolTest.totalSupply(1));

        //console.log("IdBorro1", lendingPoolTest.getIdBorrow(alice, 1));

        console.log("DataFeedETH_USD", lendingPoolTest.getDataFeed(0));
        console.log("DataFeedBTC_USD", lendingPoolTest.getDataFeed(1));
        console.log("DataFeedLINK_USD", lendingPoolTest.getDataFeed(2));
        console.log("DataFeedUSDC_USD", lendingPoolTest.getDataFeed(3));
        console.log("DataFeedDAI_USD", lendingPoolTest.getDataFeed(4));

        console.log("Link en Usdc", lendingPoolTest.getConvertedValue(2, 3));
        console.log("Eth en Btc", lendingPoolTest.getConvertedValue(0, 1));
        console.log("Btc en Usdt", lendingPoolTest.getConvertedValue(1, 3));
        console.log("Btc en Link", lendingPoolTest.getConvertedValue(1, 2));
        console.log("Btc en Dai", lendingPoolTest.getConvertedValue(1, 4));
        console.log("Dai en Eth", lendingPoolTest.getConvertedValue(4, 0));
        console.log("Usdc en Btc", lendingPoolTest.getConvertedValue(3, 1));
        console.log("Link en Usdc", lendingPoolTest.getConvertedValue(2, 3));
        console.log("Dai en Btc", lendingPoolTest.getConvertedValue(4, 1));
        console.log("Usdc en Eth", lendingPoolTest.getConvertedValue(3, 0));
        console.log("Eth en Link", lendingPoolTest.getConvertedValue(0, 2));
        console.log("Link en Ether", lendingPoolTest.getConvertedValue(2, 0));

        console.log("XXXX", lendingPoolTest.totalSupply(2));
        console.log("SUPPLY_LINK", lendingPoolTest.totalSupply(2));
        console.log("LoanCounter0", lendingPoolTest.getLoanCounter());
        lendingPoolTest.borrow(0, 2, 1 ether); //0
        console.log("UserDebt0-2", lendingPoolTest.getUserDebt(alice,0));
        console.log("LoanCounter1", lendingPoolTest.getLoanCounter());
        //lendingPoolTest.borrow(0, 2, 10 ether);//0
        lendingPoolTest.borrow(2, 1, 100 ether); //1
        console.log("UserDebt1-1", lendingPoolTest.getUserDebt(alice,1));
        console.log("SUPPLY_USDT", lendingPoolTest.totalSupply(3));
        console.log("Balance_USDT", lendingPoolTest.balanceOf(alice, 1));
        console.log("LoanCounter2", lendingPoolTest.getLoanCounter());
        lendingPoolTest.borrow(1, 3, 3 ether); //2
        console.log("UserDebt2-3", lendingPoolTest.getUserDebt(alice,2));
        console.log("LoanCounter3", lendingPoolTest.getLoanCounter());
        lendingPoolTest.borrow(3, 0, 2000 ether); //3
        console.log("UserDebt3-0", lendingPoolTest.getUserDebt(alice,3));
        lendingPoolTest.borrow(4, 0, 200 ether); //4
        console.log("UserDebt4-0", lendingPoolTest.getUserDebt(alice,4));
        lendingPoolTest.borrow(3, 4, 200 ether); //5
        console.log("UserDebt5-4", lendingPoolTest.getUserDebt(alice,5));

        uint256 debt0 = (lendingPoolTest.getUserDebt(alice,0));
        console.log("Debt0", debt0);
        //wlink.approve(address(lendingPoolTest), 100000 ether);
        wlink.approve(address(lendingPoolTest), debt0);
        //lendingPoolTest.repay(2, 0, 1208 ether, 0);
        lendingPoolTest.repay(2, 0, debt0, 0);

        uint256 debt1 = (lendingPoolTest.getUserDebt(alice,1));
        console.log("Debt1", debt1);
        wbtc.approve(address(lendingPoolTest), debt1); //link
        lendingPoolTest.repay(1, 2, debt1, 1);

        uint256 debt2 = (lendingPoolTest.getUserDebt(alice,2));
        console.log("Debt2", debt2);
        wusdt.approve(address(lendingPoolTest), debt2);
        lendingPoolTest.repay(3, 1, debt2, 2);

        uint256 debt3 = (lendingPoolTest.getUserDebt(alice,3));
        console.log("Debt3", debt3);
        weth.approve(address(lendingPoolTest), debt3); //DAI FALSO
        lendingPoolTest.repay(0, 3, debt3, 3);

        uint256 debt4 = lendingPoolTest.getUserDebt(alice,4);
        console.log("Debt4", debt4);
        weth.approve(address(lendingPoolTest), debt4);
        lendingPoolTest.repay(0, 4, debt4, 4);

        uint256 debt5 = (lendingPoolTest.getUserDebt(alice,5));
        console.log("Debt5", debt5);
        wdai.approve(address(lendingPoolTest), debt5); //DAI FALSO
        lendingPoolTest.repay(4, 3, debt5, 5);

        console.log("LoanCounter", lendingPoolTest.getLoanCounter());

        /*
        
        console.log("Supply BTC Antes borrow",lendingPoolTest.totalSupply(1));
        console.log("User collateral 0", lendingPoolTest.getUserCollateral(0, 1));
        console.log("User debt 0", lendingPoolTest.getUserDebt(alice,1, 0));

        console.log("Supply BTC Antes borrow Falla",lendingPoolTest.totalSupply(1));
        console.log("Supply USDT Antes borrow Falla",lendingPoolTest.totalSupply(3));
        lendingPoolTest.borrow(0, 2, 5 ether);
        //console.log("AmountCollateral borrow025", lendingPoolTest.getAmountCollateral());
        //console.log("Amountborrow025", lendingPoolTest.getAmount());
        
        //lendingPoolTest.borrow(2, 4, 5 ether);
        //console.log("AmountCollateral borrow245", lendingPoolTest.getAmountCollateral());
        console.log("Amountborrow245", lendingPoolTest.getAmount());
        lendingPoolTest.borrow(1, 3, 10 ether);
        console.log("AmountCollateral borrow1310", lendingPoolTest.getAmountCollateral());
        console.log("Amountborrow1310", lendingPoolTest.getAmount());
        //console.log("Borrow0 poolId", lendingPoolTest.getBorrowPoolId(alice, 0));
        
        //console.log("BorrowEXTTRA poolId", lendingPoolTest.getBorrowPoolId(alice, 5));//solo hay 5 poolId

        //lendingPoolTest.borrow(4, 0, 10 ether);
        console.log("Balance 2", lendingPoolTest.balanceOf(alice,2));
        lendingPoolTest.borrow(3, 0, 10 ether);
        //lendingPoolTest.borrow(4, 1, 20 ether);
        //console.log("IdBorrow1", lendingPoolTest.getIdBorrow(alice, 1));
        //console.log("IdBorrow2", lendingPoolTest.getIdBorrow(alice, 2));
        
        console.log("User collateral 1 despues borrow", lendingPoolTest.getUserCollateral(1, 3));
        console.log("User debt 1 despues borrow", lendingPoolTest.getUserDebt(alice,1, 3));
        //lendingPoolTest.borrow(3, 4, 5 ether);

        console.log("Supply BTC Antes repay",lendingPoolTest.totalSupply(1));
        wbtc.approve(address(lendingPoolTest), 3.75 ether);//BTC FALSO    
        console.log("User collateral 0", lendingPoolTest.getUserCollateral(0, 2));
        console.log("User debt 0", lendingPoolTest.getUserDebt(alice,0, 2));
        lendingPoolTest.repay(2, 0, 3.75 ether, 0);
        console.log("User collateral 0 despues", lendingPoolTest.getUserCollateral(0, 2));
        console.log("User debt 0 despues", lendingPoolTest.getUserDebt(alice,0, 2));
        console.log("Supply BTC Despues repay",lendingPoolTest.totalSupply(1));

        console.log("User collateral 1", lendingPoolTest.getUserCollateral(1, 0));
        console.log("User debt 1", lendingPoolTest.getUserDebt(alice,1, 0));
        //lendingPoolTest.borrow(1, 4, 5 ether);
    
        wdai.approve(address(lendingPoolTest), 3.75 ether);
        //lendingPoolTest.repay(4, 1, 3.75 ether, 6);

        wdai.approve(address(lendingPoolTest), 3.75 ether);
        //lendingPoolTest.repay(4, 2, 3.75 ether, 1);

        wbtc.approve(address(lendingPoolTest), 7.5 ether);
        lendingPoolTest.repay(3, 1, 7.5 ether, 2);
    
        weth.approve(address(lendingPoolTest), 7.5 ether);
       // lendingPoolTest.repay(0, 4, 7.5 ether, 3);
    
        weth.approve(address(lendingPoolTest), 7.5 ether);//BTC FALSO
        lendingPoolTest.repay(0, 3, 7.5 ether, 4);
    
        wbtc.approve(address(lendingPoolTest), 15 ether);
        //lendingPoolTest.repay(1, 4, 7.5 ether, 5);*/
    }
}
