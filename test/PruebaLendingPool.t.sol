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
    AToken aToken;
    ATokenDebt aTokenDebt;
    
    

    string MAINNET_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/x285eIv7gcffbvHwtnxjDVz6kIgwvuw3';
    string SEPOLIA_RPC_URL = 'https://eth-sepolia.g.alchemy.com/v2/QF_rlvr4V0ZORimK7ysBA4mJvl0Bk47c';
   
    uint256 mainnetFork;
    uint256 sepoliaFork;


        
    //30 Day ETH ATR 0xceA6Aa74E6A86a7f85B571Ce1C34f1A60B77CD29

    function setUp() public {
        //ddress owner = address(PruebaLendingPoolTest);
        weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        address _ethContractAddress = makeAddr("_ethContractAddress"); 
        address _btcContractAddress = makeAddr("_btcContractAddress"); 
        address _linkContractAddress = makeAddr("_linkContractAddress"); 
        address _usdtContractAddress = makeAddr("_usdtContractAddress"); 
        address _adaContractAddress = makeAddr("_adaContractAddress"); 
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
        deal(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, alice, 100 ether);
        vm.startPrank(alice);
        //aToken.approve(testPruebaLendingPool, 10 ether);
        console.log("Antes approve");
        weth.approve(address(pruebaLendingPoolTest), 10 ether);
        console.log("Despues approve");

        console.log("Alice's balance antes deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));

        
        pruebaLendingPoolTest.deposit(0, 10 ether);
        console.log("Alice's balance depues deposit: ", pruebaLendingPoolTest.balanceOf(alice,0));
        //pruebaLendingPoolTest.withdraw(0, 20);
        //onsole.log("Alice's balance depues withdraw: ", pruebaLendingPoolTest.balanceOf(alice,0));
        //console.log("Tokens balance depues withdraw: ", aToken.userBalance(msg.sender));
        //console.log("Tokens supply depues withdraw: ", aToken.tokenSupply());
    } 
}