// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {aToken} from "./aToken.sol";
import { getInterestRate } from "./InterestRates.sol";
import { PriceOracle } from "./PriceOracle.sol";

//COSAS A MEJORAR O EN QUE PENSAR
//-Añadir EMIT, deposit, wihtdraw, borrow y repay
//-Como llamar a las funciones mint y burn desde LendingPool?
//-Añadir Intereses / Timestamp?
//-¿Añadir balanceOf() a aToken.sol?

//DUDAS:- Problema PANIK con Foundry//Hay chainlink Feed Registry para sepolia?? ///  ¿Si para devolver deuda con Repay se envia más dinero del que hay, que ocurre? AAVE no controla que no se exceda. ///Cuantas monedas puedo usar en Sepolia? ETH, BTC, LINK, el resto son USD??? 


contract LendingPool{

    interface IaToken internal{
        function mint(address user, uint256 amount); 
        function burn(address user, uint256 amount);
}

    address public aToken;
    uint256 lastUpdatedTimestamp;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;
    

    mapping(address => uint256) asset;
    mapping(address => uint256) debt;
    mapping(address => uint256) collateral;
    mapping(address => uint256) depositTime;
    mapping(address => uint256) borrowTimestamp;

    error ItCantBeZero();
    error InsufficientFunds();
    error DebtIsLower();
    error YouAlreadyHaveDebt();

    function setToken(address _aToken) external{
        aTokenInstance = IaToken(_aToken);
    }
    function setInterestRate(address _interestRate) external{
        interestRate = _interestRate;
    }
    function setPriceOracle(address _priceOracle) external{
        priceOracle = _priceOracle;
    }

    //function deposit(address asset, uint256 amount, address onBehalfOf, uint256 referralCode) payable public{
    function deposit(address asset, uint256 amount) payable public{
        despositTime[asset] = uint256(block.timestamp);

        ///CEI: Checks, Effects, Interactions
        if (amount == 0){
            revert ItCantBeZero();
        if (msg.value == BTC){
            priceOracle.getBTC_ETHPrice()
        }
        asset[msg.sender] += amount;
        //HAY QUE MINTEAR TOKENS
        aTokenInstance.mint(msg.sender, amount);
        
        updatePrincipal();
    }

    function updatePrincipal public returns(uint256){
        uint256 timeElapsed = block.timestamp - depositTime;
        if(timeElapsed > 0){
            rate = interestRate.getInterestRate();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = asset[msg.sender] * rate * timeElapsed;
            asset[msg.sender] += interest
            depositTime[asset] = block.timestamp;
    }
        return asset[msg.sender]  
        }
    }

    function withdraw(address asset, uint256 amount, address to) public{
        ///CEI: Checks, Effects, Interactions
        if (amount > asset[msg.sender]){
            revert InsuffientFunds();
        }
        //HAY QUE QUEMAR TOKENS
        aTokenInstance.burn(msg.sender, amount);
        asset[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    //function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {
    function borrow(address asset, uint256 amount, uint256 interestRateMode)public {
        if(debt[msg.sender] > 0) revert YouAlreadyHaveDebt();
            updateBorrow();
            borrowTimestamp[msg.sender] = block.timestamp;

        if (asset[msg.sender]>amount * 125*10**16){
            //collateral[msg.sender]+=amount*125/100;
            collateral[msg.sender]+=amount * 125*10**16;
            //asset[msg.sender]-=amount*125/100;
            asset[msg.sender]-=amount * 125*10**16;
            debt[msg.sender]+=amount;

            //payable[msg.sender].transferFrom(msg.sender, address(this),amount);
            msg.sender.transferFrom(msg.sender, address(this),amount);
        }
    }

    function updateBorrow public returns(uint256){
        uint256 timeElapsed = block.timestamp - borrowTimestamp[msg.sender];
        if(timeElapsed > 0){
            rate = interestRate.getInterestBorrow();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = debt[msg.sender] * rate * timeElapsed;
            debt[msg.sender] += interest
            borrowTimestamp[msg.sender] = block.timestamp;
    }
        return debt[msg.sender]  
        }
    

    function repay(address asset, uint256 amount, uint256 rateMode, address onBehalfOf)payable public {
        if(debt<amount){
            revert DebtIsLower();
        }
        //APLICAR RATES??
        debt[msg.sender]-=amount;
        collateral[msg.sender]-=amount * 125*10**16
        //NECESITO APPROVE??
        msg.sender.transferFrom(address(this),msg.sender,amount);

    }


    function swapBorrowRateMode(address asset, uint256 rateMode) public {

    }
    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) public{
        
    }
    function liquidationCall(address asset, address debt, address user, uint256 debtToCover, bool receiveAToken) public {

    }
    function flashLoan(address receiverAddress, address[]calldata assets, uint256[]calldata amounts, uint256[]modes, address onBehalfOf, bytes calldata params, uint16 referralCode) public{

    }
    function getReserveData(address asset) public{
        //devuelve un lote de valores de una reserve
    }
    function getUserAccountData(address user) public{
        //devuelve los datos de las reserve del user
    }
    function getConfiguration(address asset) public{
        //devuelve la configuracion de la reserve
    }
    //hay mas funciones que no me parecen relevantes
}