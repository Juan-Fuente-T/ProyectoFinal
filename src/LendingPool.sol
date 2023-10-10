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
//-Usar TransferFrom y ¿bool sent? y aprove
//-Ya no necesito todas las direcciones de los ethContractAddress, etc.Chequear aqui y en priceOracle que se borren. 

//DUDAS:- Problema PANIK con Foundry//Hay chainlink Feed Registry para sepolia?? ///  ¿Si para devolver deuda con Repay se envia más dinero del que hay, que ocurre? AAVE no controla que no se exceda. ///Cuantas monedas puedo usar en Sepolia? ETH, BTC, LINK, el resto son USD??? 

interface IaToken {
    function mint(address user, uint256 amount); 
    function burn(address user, uint256 amount);
}

contract LendingPool{
    struct Pool{
        mapping (address => uint256) balances;
        uint256 totalSupply;
        uint256 poolId;
    }
    Pool[] public assets;
    //Pool storage pool = assets[poolId];
    //mapping (uint256 => Pool) public assets;

    //event Deposit(bytes32 poolId, address indexed user, uint256 amount);
    //event Withdraw(bytes32 poolId, address indexed user, uint256 amount);

    /*PriceOracle priceOracle = new PriceOracle; // Se inicializa el contrato PriceOracle 
    address ethContractAddress = priceOracle.ethContractAddress();
    address btcContractAddress = priceOracle.btcContractAddress();
    address linkContractAddress = priceOracle.linkContractAddress();
    address usdtContractAddress = priceOracle.usdtContractAddress();
    address adaContractAddress = priceOracle.adaContractAddress();*/

    address public owner;
    address public aToken;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;
    /*uint256 ethPool;
    uint256 btcPool;
    uint256 linkPool;
    uint256 usdtPool;
    uint256 adaPool;*/

    modifier onlyOwner (){
        require (msg.sender == owner, "Only the owner can do this");
        _;
    }
    function createPool(uint256 _poolId, uint256 _initialSupply) public onlyOwner{
        Pool memory newPool = Pool({
        poolId : _poolId,
        totalSupply : _initialSupply;
        })
        assets.push(newPool);
    }
    constructor(){
        owner = msg.sender;        
        createPool(0, 100);
        createPool(1, 100);
        createPool(3, 1000);
        createPool(4, 10000);
        createPool(5, 1000);   
    }

    /*uint256 priceFeedETH_BTC;
    uint256 priceFeedBTC_ETH;
    uint256 priceFeedLINK_ETH;
    uint256 priceFeedETH_LINK;*/

    //mapping(address => uint256) asset;
    mapping(address => uint256) debt;
    mapping(address => uint256) collateral;
    mapping(address => mapping(uint256 => uint256)) depositTimestamp;
    mapping(address => mapping(uint256 => uint256)) borrowTimestamp;

    error ItCantBeZero();
    error InsufficientFunds();
    error DebtIsLower();
    error YouAlreadyHaveDebt();

    function setOwner(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    function setToken(address _aToken) external{
        aToken = IaToken(_aToken);
    }
    function setInterestRate(address _interestRate) external{
        interestRate = _interestRate;
    }
    function setPriceOracle(address _priceOracle) external{
        priceOracle = _priceOracle;
    }

    function checkBalances(address user, uint256 poolId) internal view returns(uint256){
        Pool memory pool = assets[poolId];
        if (pool.balance[user] > 0){
            return return.pool.balances[user]
        }else{
            return 0;
        }
    }

    //function deposit(address asset, uint256 amount, address onBehalfOf, uint256 referralCode) payable public{
    function deposit(uint256 poolId, uint256 amount) payable public{
        ///CEI: Checks, Effects, Interactions
        if (amount == 0){
            revert ItCantBeZero();
        }
        if (!(checkBalances(msg.sender, poolId) > 0)){
            depositTimestamp[msg.sender][poolId] = uint256(block.timestamp);
        }
    
        updatePrincipal();

        if (poolid == 1){
            priceFeedBTC_ETH = priceOracle.getBTC_ETHPrice()
            uint256 amountAToken = amount * priceFeedBTC_ETH;
            aToken.mint(msg.sender, amountAToken);

        }
        pool.totalSuppy += amount;
        
        pool.balances[msg.sender] += amount;
    }
    //Como calcular actualizar los intereses? Si se llama a la funcion updatePrincipal() despues del deposit, puede pasar, por ejemplo, un año y al hacer deposit de nuevo y no se habrán actualizado los intereses. Si se usa la funcion antes del propio deposit
    function updatePrincipal() public returns(uint256){
        uint256 timeElapsed = block.timestamp - depositTimestamp[msg.sender][poolId];
        if(timeElapsed > 0){
            rate = interestRate.getInterestRate();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;

            //CUIDADO QUE SON SEGUNDOS
            uint256 interest = pool.balances[msg.sender] * rate * timeElapsed;
            pool.balances[msg.sender] += interest;
            depositTimestamp[msg.sender][poolId] = block.timestamp;
        }
        return pool.balances[msg.sender]  
    }
    

    function withdraw(uint256 poolId, uint256 amount) public{
        upddatePrincipal();

        ///CEI: Checks, Effects, Interactions
        if (amount > pool.balance[msg.sender]){
            revert InsufficientFunds();
        }
        //HAY QUE QUEMAR TOKENS
        aToken.burn(msg.sender, amount);
        pool.balance[msg.sender] -= amount;
        msg.sender.transferFrom(msg.sender, address(this),amount);
        
        //CUIDADO QUE SON TOKENS; NO ETHER
    }

    //function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {
    function borrow(uint256 poolId, uint256 amount)public {
        if(debt[msg.sender] > 0) revert YouAlreadyHaveDebt();
            updateBorrow();
            borrowTimestamp[msg.sender][poolId]= block.timestamp;

        if (pool.balances[msg.sender]>amount * 125 * 10**16){
            //collateral[msg.sender]+=amount*125/100;
            collateral[msg.sender]+=amount * 125 * 10**16;
            //asset[msg.sender]-=amount*125/100;
            pool.balances[msg.sender]-=amount * 125*10**16;
            debt[msg.sender]+=amount;

            //payable[msg.sender].transferFrom(msg.sender, address(this),amount);

            //CUIDADO QUE SON TOKENS; NO ETHER
            msg.sender.transferFrom(msg.sender, address(this),amount);
        }
    }

    function updateBorrow() public returns(uint256){
        uint256 timeElapsed = block.timestamp - depositTimestamp[debt[msg.sender]]
        if(timeElapsed > 0){
            rate = interestRate.getInterestBorrow();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = debt[msg.sender] * rate * timeElapsed; //CUIDADO, SON SEGUNDOS
            debt[msg.sender] += interest
            borrowTimestamp[msg.sender][poolId] = block.timestamp;
    }
        return debt[msg.sender]  
        }
    

    function repay(uint256 poolId, uint256 amount)payable public {
        updateBorrow();

        if(debt < amount){
            revert DebtIsLower();
        }

        debt[msg.sender]-=amount;
        collateral[msg.sender]-=amount * 125*10**16
        //NECESITO APPROVE??
        msg.sender.transferFrom(address(this),msg.sender,amount);

    }
}

/*
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
}*/