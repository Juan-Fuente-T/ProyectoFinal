// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol";
import "./aToken.sol";

//COSAS A MEJORAR O EN QUE PENSAR
//-Añadir EMIT, deposit, wihtdraw, borrow y repay
//-Como llamar a las funciones mint y burn desde LendingPool?
//-Añadir Intereses / Timestamp?
//-¿Añadir balanceOf() a aToken.sol?

//DUDAS:-¿Tengo que tener los contratos ERC20 (o los que importe) fisicamente en mi respositorio, no? Tengo que importar mi propio archivo aToken.sol,no?///  ¿Si para devolver deuda con Repay se envia más dinero del que hay, que ocurre? AAVE no controla que no se exceda. 

mapping(address => uint256) asset;
mapping(address => uint256) debt;
mapping(address => uint256) collateral;
error ItCantBeZero();
error InsufficientFunds();
error DebtIsLower();

contract LendingPool{
    function deposit(address asset, uint256 amount, address onBehalfOf, uint256 referralCode) payable public{
        ///CEI: Checks, Effects, Interactions
        if (amount == 0){
            revert ItCantBeZero();
        //HAY QUE MINTEAR TOKENS
        asset[msg.sender] += amount;
        }

    function withdraw(address asset, uint256 amount, address to) public{
        ///CEI: Checks, Effects, Interactions
        if (amount > asset[msg.sender]){
            revert InsuffientFunds();
        }
        //HAY QUE QUEMAR TOKENS
        asset[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {
        if (asset[msg.sender]>amount*125/100){
            collateral[msg.sender]+=amount*125/100;
            asset[msg.sender]-=amount*125/100;
            debt[msg.sender]+=amount;
            payable[msg.sender].transfer(amount);
        }
    }
    function repay(address asset, uint256 amount, uint256 rateMode, address onBehalfOf)payable public {
        if(debt<amount){
            revert DebtIsLower();
        }
        debt[msg.sender]-=amount;
        collateral[msg.sender]*125/100-=amount

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