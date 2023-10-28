// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//ADDRESS DEPLOY Pruebas LendingPool Sepolia 0xC98B70f92e5511dC2acDa6f2BAadA4ed5ec3A786
//wrapped ether sepolia bueno: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./aToken.sol";
import {ATokenDebt} from "./aTokenDebt.sol";
import { InterestRates } from "./InterestRates-copia.sol";
import { PriceOracle } from "./PriceOracle-copia.sol";
import { IWETH } from "../src/libraries/IWETH.sol";
import { LoanContract } from "./LoanContract.sol";
import { ERC20 } from "./libraries/ERC20.sol";
import { SafeMath } from "./libraries/SafeMath.sol";
import { ATokenEth } from "./libraries/wETH.sol";
import { ATokenBtc } from "./libraries/wBTC.sol";
import { ATokenLink } from "./libraries/wLINK.sol";
import { ATokenUsdt } from "./libraries/wUSDT.sol";
import { ATokenAda } from "./libraries/wADA.sol";
//mi AToken deployado en sepolia fork 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62
//mi ATokenDebt deployado en sepolia fork 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af
//WETH Gateway 0xD322A49006FC828F9B5B37Ab215F99B4E5caB19C

//MANEJAR Deadline de permit en la INTERFAZ del user
//EN PERMIT hay datos concretos temporalmente: deadline, v,r,sea
//QUITAR ciertas DIRECCIONES del CONSTRUCTOR, descomentar FUNCIONES
//Ojo con orden y direcciones necesarias para deploy y para onwer al desplegar

///contrato WBTC aqui https://www.alchemy.com/smart-contracts/wbtc

interface IWrappedTokenGetway{
    function depositETH(address pool, address onBehalfOf, uint16 referralCode) external payable;
    function withdrawETH(address pool, uint256 amount, address to) external;
}

interface IwBTC{
    function mint(address _to,uint256 _amount) external returns (bool);
    //function burn(uint256 _value) external;
    function _burn(address _who, uint256 _value) external;
    function approve(address _spender,uint256 _value) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to,uint256 _value) external returns (bool);
}


//interface combinada para usar con aToken y aTokenDebt
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

contract LendingPool{
    using SafeMath for uint;

    struct Pool{
        uint256 poolId;
        uint256 totalSupply;
        uint256 userDebt;
        uint256 userCollateral;
        uint256 totalDebt;
    }
   
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

    address owner;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;
    uint256 amountAToken;
    uint256 amount;
    uint256 amountCollateral;
    //uint256 idBorrow;
    
    uint256 priceFeedETH_BTC;
    uint256 priceFeedBTC_ETH;
    uint256 priceFeedLINK_ETH;
    uint256 priceFeedETH_LINK;
    uint256 priceFeedUSDT_ETH;
    uint256 priceFeedETH_USDT;
    uint256 priceFeedADA_ETH;
    uint256 priceFeedETH_ADA;

    InterestRates public  interestRates;
    PriceOracle public  priceOracle;
    LoanContract public loanContract;

    ATokenEth public aTokenEth;
    ATokenBtc public aTokenBtc;
    ATokenLink public aTokenLink;
    ATokenUsdt public aTokenUsdt;
    ATokenAda public aTokenAda;
    AToken public aToken;
    ATokenDebt public aTokenDebt;

    IaToken public weth;
    IaToken public wbtc;
    IaToken public wlink;
    IaToken public wusdt;
    IaToken public wada;

    //IWETH public weth;
    IwBTC public iwbtc;

    


    modifier onlyOwner (){
        require (msg.sender == owner, "Only the owner can do this");
        _;
    }
    function createPool(uint256 _poolId, uint256 _initialSupply) public onlyOwner {
        Pool storage pool = assets[_poolId];
        pool.poolId = _poolId;
        pool.totalSupply = _initialSupply;
        //pool.balances[msg.sender];
        //assets[_poolId] = newPool;
    }
    //SOLO PASAR ESTAS DIRECCION POR PARAMETRO PARA TEST, EN PRODUCCION SE USAN FUNCIONES PARA asignar las direcciones a los contratos importados
    //DESCOMENTAR LAS FUNCIONES
    //constructor(PriceOracle _priceOracle, InterestRates _interestRates, LoanContract _loanContract){
    constructor(){
        //priceOracle = PriceOracle(_priceOracle);
        //interestRates = InterestRates(_interestRates);
        //loanContract = LoanContract(_loanContract);
        //weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        //iwbtc = IwBTC(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        //wbtc = IaToken(address (new aTokenBtc()));
        //wusdt = IaToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        //wusdt = IaToken(address (new aTokenUsdt()));
        //wlink = IaToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        //wlink = IaToken(address(new aTokenLink()));
        //wada = IaToken(0x56694577564FdD577a0ABB20FE95C1E2756C2a11);
        //wada = IaToken(address (new aTokenAda()));
        //aToken = IaToken(0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62);
        aTokenEth = new ATokenEth();
        aTokenBtc = new ATokenBtc();
        aTokenLink = new ATokenLink();
        aTokenUsdt = new ATokenUsdt();
        aTokenAda = new ATokenAda();
        aToken = new AToken();
        aTokenDebt = new ATokenDebt();
        //gateway = IWrappedTokenGetway(_gateway);

        owner = msg.sender;        
        createPool(0, 100000000000000000000);
        createPool(1, 100000000000000000000);
        createPool(2, 1000000000000000000000);
        createPool(3, 10000000000000000000000);
        createPool(4, 1000000000000000000000);   
    }

    mapping(uint256 => Pool)assets;
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(address => mapping(uint256 => Pool)) debt;
    mapping(address => mapping(uint256 => Pool)) collateral;
    mapping(address => mapping(uint256 => uint256)) depositTimestamp;
    mapping(address => mapping(uint256 => uint256)) borrowTimestamp;
    //mapping (address => uint256) userCollateral;
    //mapping (address => uint256) userDebt;

    error ItCantBeZero();
    error InsufficientFunds();
    error DebtIsLower();
    error YouAlreadyHaveDebt();
    error YouDontHaveDebt();
    error InsufficientCollateral();
    error NotApproved();
    error MintFailed();
    error TransferFailed();

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    function setOwner(address newOwner) public onlyOwner{
        owner = newOwner;
    }
    ///////////Creo que esta funcion no hace falta
    /*function setTokens(address _aToken, address _aTokenDebt) public onlyOwner{
        aToken = IaToken(_aToken);
        aTokenDebt = IaToken(_aTokenDebt);
    }*/
    

    /*function setInterestRates(address _interestRates) public{
        interestRates = InterestRates(_interestRates);
    }
    function setPriceOracle(address _priceOracle) public onlyOwner
        priceOracle = PriceOracle(_priceOracle);

    // Función para configurar la dirección del contrato de préstamo
    function setLoanContract(address _loanContract) public onlyOwner {
        loanContract = LoanContract(_loanContract);
    }

    }*/

    /*function wETHTotalSupply() public returns(uint256 aTokenTotalSupply){
        return weth.totalSupply;
    }
    function wETHUserBalance(address user) public returns(uint256 aTokenTotalSupply){
        return weth.balanceOf[user];
    }*/

    function increaseTotalSupply( uint256 idBorrow, uint256 _amount) public {
        assets[idBorrow].totalSupply += _amount;
    }
    function decreaseTotalSupply(uint256 idBorrow, uint256 _amount) public {
        assets[idBorrow].totalSupply -= _amount;
    }
    function increaseTotalDebt(uint256 idBorrow, uint256 _amount) public {
        assets[idBorrow].totalDebt += _amount;
    }
    function decreaseTotalDebt(uint256 idBorrow, uint256 _amount) public{
        assets[idBorrow].totalDebt -= _amount;
    }

    function increaseCollateral(address user, uint256 idBorrow, uint256 _amount) public {
        collateral[user][idBorrow].userCollateral += _amount;
    }
    function decreaseCollateral(address user, uint256 idBorrow, uint256 _amount) public {
        collateral[user][idBorrow].userCollateral -= _amount;
    }
    function increaseDebt(address user, uint256 idBorrow, uint256 _amount) public {
        debt[user][idBorrow].userDebt += _amount;
    }
    function decreaseDebt(address user, uint256 idBorrow, uint256 _amount) public {
        debt[user][idBorrow].userDebt -= _amount;
    }
    function increaseBalanceOf(address user, uint256 poolId, uint256 _amount) public {
        balances[user][poolId] += _amount;
    }
    function decreaseBalanceOf(address user, uint256 poolId, uint256 _amount) public {
        balances[user][poolId] -= _amount;
    }


    function getAmountCollateral() public view returns (uint256){
        return amountCollateral;
    }
    function getAmount() public view returns (uint256){
        return amount;
    }
    function getAmountAToken() public view returns (uint256){
        return amountAToken;
    }
    function balanceOf(address, uint256 poolId) public view returns (uint256){
        return balances[msg.sender][poolId];
    }

    function totalSupply(uint256 poolId) public view returns(uint256){
        return assets[poolId].totalSupply;
    }
    function getCollateral(address user, uint256 idBorrow) public view returns(uint256){
        return collateral[user][idBorrow].userCollateral;
    }
    function getDebt(address user, uint256 idBorrow) public view returns(uint256){
        return debt[user][idBorrow].userDebt;
    }
    //ELIMINAR esta funcion despues de los test
    function setTotalSupplyAndOthers(address user, uint256 poolId, uint256 cantidadTotalSupply, uint256 cantidadUser) public {
        assets[poolId].totalSupply+= cantidadTotalSupply;
        balances[user][poolId]+= cantidadUser *1e18;
    }

    function deposit(uint256 poolId, uint256 _amount) payable public{
        ///CEI: Checks, Effects, Interactions
        // Se verifica que el monto sea menor o igual a los fondos disponibles
        amount = _amount *10**18;

        if (!(amount > 0)){
            revert ItCantBeZero();
        }

        updatePrincipal(poolId);
        
        /*(bool approved) = aToken.approve(msg.sender, amount);
        if (!approved){
            revert NotApproved();
        }
        aToken.mint(msg.sender, amount);*/       
        if (poolId == 0){
            
            // Convertir ETH a wETH
            //weth.deposit{value: msg.value}();
            //amountAToken = amount;
            (bool approved) = weth.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            //aToken.permit(owner, msg.sender, amount, block.timestamp + 30, 0, bytes32(0), bytes32(0));
            aToken.mint(msg.sender, amount);
            //aToken.userBalance(msg.sender);
            /*(bool success) = weth.transfer(address(this), amount);
            if(!success){
                revert TransferFailed();
            }*/
        }
        else if (poolId == 1){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;

            (bool approved) = aTokenBtc.approve(address(this), amount);
            if (!approved){
                revert NotApproved();

            aToken.mint(msg.sender, amount);

            (bool success) = aTokenBtc.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }
            }
            
            //aTokenBtc.mint(msg.sender, amount);
            /*(bool sent)=aTokenBtc.mint(msg.sender, amount);
            if (!sent){
                revert MintFailed();
            }*/

            
        }
        
        else if (poolId == 2){
            //priceFeedLINK_ETH = priceOracle.testGetLINK_ETHPrice();
            //amountAToken = amount * priceFeedLINK_ETH;
            //wlink.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            (bool approved) = aTokenLink.approve(msg.sender, amount);
            if (!approved){
                revert NotApproved();
            aToken.mint(msg.sender, amount);

            (bool success) = aTokenLink.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }
            }
            
            
            //aTokenLink.mint(msg.sender, amount);
            
        }
        else if (poolId == 3){
            //priceFeedUSDT_ETH = priceOracle.testGetUSDT_ETHPrice();
            //amountAToken = amount * priceFeedUSDT_ETH;
            //wlink.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            (bool approved) = aTokenUsdt.approve(msg.sender, amount);
            if (!approved){
                revert NotApproved();

            aToken.mint(msg.sender, amount);

            (bool success) = aTokenUsdt.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }
            }
            
           // aTokenUsdt.mint(msg.sender, amount);
            
        }
        else if (poolId == 4){
            //priceFeedADA_ETH = priceOracle.testGetADA_ETHPrice();
            //amountAToken = amount * priceFeedADA_ETH;
            //wada.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            (bool approved) = aTokenAda.approve(msg.sender, amount);
            if (!approved){
                revert NotApproved();

            aToken.mint(msg.sender, amount);

            (bool success) = aTokenAda.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }
            }
           
            //aTokenAda.mint(msg.sender, amount);
        }

        //aToken.mint(msg.sender, amountAToken);
        emit Deposit(msg.sender, amount);
        increaseTotalSupply(poolId, amount);
        //assets[poolId].totalSupply += amount;
        increaseBalanceOf(msg.sender, poolId, amount);
        //balances[msg.sender][poolId] += amount;

    }
                               
    /*function getUserDebt(address) public view returns (uint256){
        return userDebt[msg.sender];
    }
    function getUserCollateral(address) public view returns (uint256){
        return userCollateral[msg.sender];
    }*/

    /*function getCollateral(address user, uint256 idBorrow, uint256 poolId) public view returns (uint256) {
        return collateral[user][idBorrow][poolId];
    }

    function getDebt(address user, uint256 idBorrow, uint256 poolId) public view returns (uint256) {
        return debt[user][idBorrow][poolId];
    }*/

    //Como calcular actualizar los intereses? Si se llama a la funcion updatePrincipal() despues del deposit, puede pasar, por ejemplo, un año y al hacer deposit de nuevo y no se habrán actualizado los intereses. Si se usa la funcion antes del propio deposit
    function updatePrincipal(uint256 poolId) public returns(uint256){

        if (balances[msg.sender][poolId] == 0){
            depositTimestamp[msg.sender][poolId] = uint256(block.timestamp);
        }
        uint256 timeElapsed = block.timestamp - depositTimestamp[msg.sender][poolId];
        if(timeElapsed > 0){
            //rate = interestRates.getInterestRate();
            //rate = interestRates.getInterestRate();
            rate = (5/(assets[poolId].totalDebt))/(assets[poolId].totalSupply);
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;

            //CUIDADO QUE SON SEGUNDOS
            //uint256 interest = balances[msg.sender][poolId] * (rate * timeElapsed);
            //uint256 interest = (balances[msg.sender][poolId]) * ((rate / (365 * 24 * 60 * 60)) * timeElapsed); //CUIDADO, SON SEGUNDOS
            uint256 interest = ((balances[msg.sender][poolId]) * ((rate / (365 * 24 * 60 * 60)) * timeElapsed))/100; //CUIDADO, SON SEGUNDOS
            balances[msg.sender][poolId] += interest;
            depositTimestamp[msg.sender][poolId] = block.timestamp;
        }
        return balances[msg.sender][poolId];  
    }
    

    function withdraw(uint256 poolId, uint256 _amount) public{
        amount = _amount *10**18;

        updatePrincipal(poolId);

        ///CEI: Checks, Effects, Interactions

        // Se verifica que el monto sea menor o igual a los fondos disponibles, en caso contrario se cancela la transaccion
        if (amount > balances[msg.sender][poolId]){
            revert InsufficientFunds();
        }
        // Se queman tokens aToken del usuario
        //aToken.burn(msg.sender, amount);
    
        // Se llama a la función permit para permitir el gasto desde el contrato
        //aToken.permit(address(this), msg.sender, amount, deadline, v, r, s);

        //Se emite la notificacion del evento
        emit Withdraw(msg.sender, amount);
        ///////Hacer bool sent de mint y el transfer del withdraw y repay

        // Se actualiza los balances y el suministro total
        
        if (poolId == 0){
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //amountAToken = amount;
            //aTokenDebt.permit(address(this), msg.sender, amount, block.timestamp + 30, 0, bytes32(0), bytes32(0));
            (bool approved) = weth.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aToken.burn(msg.sender, amount);

            /*(bool success) = weth.transfer(msg.sender, amount);
            if(!success){
                revert TransferFailed();
            }*/
        }

        if (poolId == 1){
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            (bool approved) = aTokenBtc.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aToken.burn(msg.sender, amount);

            /*(bool success) = aTokenBtc.transfer(msg.sender, amount);
            if(!success){
                revert TransferFailed();
            }*/
        }

        if (poolId == 2){
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedLINK_ETH = priceOracle.testGetLINK_ETHPrice();
            //amountAToken = amount * priceFeedLINK_ETH;
            (bool approved) = aTokenLink.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aToken.burn(msg.sender, amount);

            /*(bool success) = aTokenLink.transfer(msg.sender, amount);
            if(!success){
                revert TransferFailed();
            }*/
        }

        if (poolId == 3){
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedUSDT_ETH = priceOracle.testGetUSDT_ETHPrice();
            //amountAToken = amount * priceFeedUSDT_ETH;
            (bool approved) = aTokenUsdt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aToken.burn(msg.sender, amount);

           /* (bool success) = aTokenUsdt.transfer(msg.sender), amount);
            if(!success){
                revert TransferFailed();
            }*/
        }

        if (poolId == 4){
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedADA_ETH = priceOracle.testGetADA_ETHPrice();
            //amountAToken = amount * priceFeedADA_ETH;
            (bool approved) = aTokenAda.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aToken.burn(msg.sender, amount);

            /*(bool success) = aTokenAda.transfer
            (msg.sender, amount);
            if(!success){
                revert TransferFailed();
            }*/
        }
        decreaseBalanceOf(msg.sender,poolId, amount);
        //balances[msg.sender][poolId] -= amount;
        decreaseTotalSupply(poolId, amount);
        //assets[poolId].totalSupply -= amount;
        //aTokenDebt.burn(msg.sender, amountAToken);
    }

    //function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {
    


function borrow(address user, uint256 idBorrow, uint256 poolId, uint256 _amount) public {
    amountCollateral = _amount *10**18;
    amount = _amount * LTV;
  
        //updateBorrow(idBorrow);

        if (!(balanceOf(msg.sender,poolId) > amountCollateral)){
            revert InsufficientCollateral();
        }   
       
        if (idBorrow == 0){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aTokenDebt.mint(msg.sender, amount);
        }      
        if (idBorrow == 1){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aTokenDebt.mint(msg.sender, amount);
        }      
        if (idBorrow == 2){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aTokenDebt.mint(msg.sender, amount);
        }      
        if (idBorrow == 3){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aTokenDebt.mint(msg.sender, amount);
        }      
        if (idBorrow == 4){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            aTokenDebt.mint(msg.sender, amount);
        }      
        decreaseBalanceOf(msg.sender, poolId, amountCollateral);
        increaseCollateral(msg.sender,idBorrow,amountCollateral);
        increaseDebt(msg.sender,idBorrow,amount);
        increaseTotalDebt(idBorrow, amount); 
        decreaseTotalSupply(idBorrow, amount);

        emit Borrow(msg.sender, amount);
        
    }


        //MINTEAR aTokenDebt
        
            //loanContract.borrow(msg.sender, idBorrow, poolId, amount, amountCollateral);
/*
            if (idBorrow == 0){
                if (poolId == 0){
                increaseBalanceOf(msg.sender, 0, 99999999999999999999999999);
                increaseDebt(msg.sender,0,0,777777777777777777777777777777);
                loanContract.borrow(msg.sender, idBorrow, poolId, amount, amountCollateral);
                }
            }
*/


        
            

    /*if (debt[msg.sender][idBorrow] > 0) {
        borrowTimestamp[msg.sender][idBorrow] = block.timestamp;
        revert YouAlreadyHaveDebt();
    }*/

    /*if (idBorrow == 0) {
        if (poolId == 1) {
            //updateBorrow(poolId);
            // Se realiza la transferencia de tokens desde el contrato al usuario
            // bool sent = weth.transfer(msg.sender, amount);
            // require(sent, "Withdraw failed");
            // collateral[msg.sender] += amount * 125 * 10**16;
            priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            amountCollateral = amount * priceFeedBTC_ETH * 125/100;

            if (balances[msg.sender][poolId] > amountCollateral) {
                collateral[msg.sender][idBorrow] += amountCollateral;
                balances[msg.sender][poolId] -= 
                amountCollateral;
                debt[msg.sender][idBorrow] += amount;
            }

            // asset[msg.sender] -= amount * 125 * 10**16;
            // aTokenDebt.mint(msg.sender, amountAToken);
            // payable[msg.sender].transferFrom(msg.sender, address(this), amount);
            // aTokenDebt.permit(address(this), msg.sender, amount, deadline, v, r, s);
            // aTokenDebt.permit(address(this), msg.sender, amount, 0, 0, bytes32(0), bytes32(0));
            // CUIDADO QUE SON TOKENS; NO ETHER
            // bool sent = aTokenDebt.transferFrom(address(this), msg.sender, amount);

            // require(sent, "Borrow failed");
        }
        if (poolId == 0) {
            //updateBorrow(poolId);
            // Se realiza la transferencia de tokens desde el contrato al usuario
            // bool sent = weth.transfer(msg.sender, amount);
            // require(sent, "Withdraw failed");
            // collateral[msg.sender] += amount * 125 * 10**16;
            amountCollateral = amount * 125 / 100;

            if (balances[msg.sender][poolId] > amountCollateral) {
                collateral[msg.sender][idBorrow] += amountCollateral;
                balances[msg.sender][poolId] -= amountCollateral;
                debt[msg.sender][idBorrow] += amount;
            }

            // asset[msg.sender] -= amount * 125 * 10**16;
            // aTokenDebt.mint(msg.sender, amountAToken);
            // payable[msg.sender].transferFrom(msg.sender, address(this), amount);
            // aTokenDebt.permit(address(this), msg.sender, amount, deadline, v, r, s);
            // aTokenDebt.permit(address(this), msg.sender, amount, 0, 0, bytes32(0), bytes32(0));
            // CUIDADO QUE SON TOKENS; NO ETHER
            // bool sent = aTokenDebt.transferFrom(address(this), msg.sender, amount);

            // require(sent, "Borrow failed");
            }
        }*/

        // require(sent, "Borrow failed");



    function updateBorrow(uint256 idBorrow) public returns(uint256){
        
        if (debt[msg.sender][idBorrow].userDebt == 0){
           borrowTimestamp[msg.sender][idBorrow] = block.timestamp; 
        } 

        uint256 timeElapsed = block.timestamp - borrowTimestamp[msg.sender][idBorrow];
        if(timeElapsed > 0){
            //rate = interestRates.getInterestBorrow();
            rate = (5/(assets[idBorrow].totalDebt))/(assets[idBorrow].totalSupply);
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = getDebt(msg.sender, idBorrow) * (rate / (365 * 24 * 60 * 60)) * timeElapsed; //CUIDADO, SON SEGUNDOS
            debt[msg.sender][idBorrow].userDebt = interest;
            borrowTimestamp[msg.sender][idBorrow] = block.timestamp;
        }
        return debt[msg.sender][idBorrow].userDebt;  
    }

    //En REPAY la cantidad que elige el user no es el collateral sino la deuda. 
    //Se divide entre LTV para saber la cantidad de collateral y balance a aumnetar
    function repay(uint256 idBorrow, uint256 _amount)payable public {
        amountCollateral = _amount / LTV;
        amount = _amount *10**18;

        //updateBorrow(idBorrow);

        

        if(debt[msg.sender][idBorrow].userDebt < amount){
            revert DebtIsLower();
        }
        if(!(debt[msg.sender][idBorrow].userDebt > 0)){
            revert YouDontHaveDebt();
        }
        emit Repay(msg.sender, idBorrow);

        if (idBorrow == 0){
            (bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            revert NotApproved();
            aTokenDebt.burn(msg.sender, amount);
        }
        if (idBorrow == 1){
            //iwbtc._burn(msg.sender, amount);
            aTokenDebt.burn(msg.sender, amount);
        }
        if (idBorrow == 2){
            //wlink.burn(msg.sender, amount);
            aTokenDebt.burn(msg.sender, amount);
        }
        if (idBorrow == 3){
            //wusdt.burn(msg.sender, amount);
            aTokenDebt.burn(msg.sender, amount);
        }
        if (idBorrow == 4){
            //wada.burn(msg.sender, amount);
            aTokenDebt.burn(msg.sender, amount);
        }
        decreaseDebt(msg.sender,idBorrow,amount);
        //debt[msg.sender][idBorrow].userDebt -= amount;
        decreaseTotalDebt(idBorrow,amount);
        decreaseCollateral(msg.sender, idBorrow, amountCollateral);
        //collateral[msg.sender][idBorrow].userCollateral-= amountCollateral;
        //aTokenDebt.burn(msg.sender, amount);
        increaseBalanceOf(msg.sender, idBorrow, amountCollateral);
        //balances[msg.sender][idBorrow] += amountCollateral ;
        increaseTotalSupply( idBorrow, amount);
        
    }
 

/*

        // Se realiza la transferencia de tokens desde el contrato al usuario
        bool sent = aToken.transferFrom(address(this), msg.sender,amount);
        require(sent, "Wihtdraw failed");
*/
}

/* ###########################################
Cosas a hacer la desplefar el contrato
- Ver todas las dependencias de contratos al despliegue
- Descomentar funciones para dar direcciones al desplegar
- Quitar Address hardcodeada en AToken y ATokenDebt
*/