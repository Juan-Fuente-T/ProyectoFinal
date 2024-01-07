// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "../aToken.sol";
import {ATokenDebt} from "../aTokenDebt.sol";
import {InterestRates} from "./InterestRates.sol";
import {PriceOracle} from "./PriceOracle.sol";

//COSAS A MEJORAR O EN QUE PENSAR

//MANEJAR Deadline de permit en la INTERFAZ del user
//EN PERMIT hay datos concretos temporalmente: deadline, v,r,s
//-Añadir Intereses / Timestamp? CREO QUE YA ESTA Bien, comprobar los calculos

//-¿Añadir balanceOf() a aToken.sol??
//ACtualizar cantidades de inicio en las pool a ¿+18ceros?

//DUDAS: -ORDEN de las cosas, que va primero, event, constructor, variables, modifier, mappings, errors???? // ¿Si para devolver deuda con Repay se envia más dinero del que hay, que ocurre? AAVE no controla que no se exceda. ///Cuantas monedas puedo usar en Sepolia? ETH, BTC, LINK, el resto son USD???
//Direcciones para intereses. DEPOSIT STAKE Eth Staking ATR??
//BORROW BTC week Curve 2??
//si deposit ETH puedo devolver en wihdraw wETH??
// SI EL USER DEPOSITA ETH NATIVO HE DE DEVOLVERLE ETH NATIVO, o wETH?
//interface combinada para usar con aToken y aTokenDebt
///////¿Como devolver en REPAY una cantidad que es fraccion, por ejemplo el collateral es 7 y la deuda 5,25, como devuelvo es deuda??
interface ICombinedToken {
    function mint(address user, uint256 amount) external;

    function burn(address user, uint256 amount) external;

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

contract LendingPool {
    struct Pool {
        uint256 poolId;
        uint256 totalSupply;
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
    ICombinedToken public aToken;
    ICombinedToken public aTokenDebt;
    InterestRates public interestRates;
    PriceOracle public priceOracle;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;

    /*uint256 ethPool;
    uint256 btcPool;
    uint256 linkPool;
    uint256 usdtPool;
    uint256 adaPool;*/

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    function createPool(
        uint256 _poolId,
        uint256 _initialSupply
    ) public onlyOwner {
        Pool storage pool = assets[_poolId];
        pool.totalSupply = _initialSupply;
        //pool.balances[msg.sender];
        //assets[_poolId] = newPool;
    }

    constructor() {
        owner = msg.sender;
        createPool(0, 100);
        createPool(1, 100);
        createPool(2, 1000);
        createPool(3, 10000);
        createPool(4, 1000);
    }

    uint256 priceFeedETH_BTC;
    uint256 priceFeedBTC_ETH;
    uint256 priceFeedLINK_ETH;
    uint256 priceFeedETH_LINK;
    uint256 priceFeedUSDT_ETH;
    uint256 priceFeedETH_USDT;
    uint256 priceFeedADA_ETH;
    uint256 priceFeedETH_ADA;

    mapping(uint256 => Pool) assets;
    mapping(address => uint256) balances;
    mapping(address => uint256) debt;
    mapping(address => uint256) collateral;
    mapping(address => mapping(uint256 => uint256)) depositTimestamp;
    mapping(address => mapping(uint256 => uint256)) borrowTimestamp;

    error ItCantBeZero();
    error InsufficientFunds();
    error DebtIsLower();
    error YouAlreadyHaveDebt();

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setTokens(address _aToken, address _aTokenDebt) public {
        aToken = ICombinedToken(_aToken);
        aTokenDebt = ICombinedToken(_aTokenDebt);
    }

    function setInterestRates(address _interestRates) public {
        interestRates = InterestRates(_interestRates);
    }

    function setPriceOracle(address _priceOracle) public {
        priceOracle = PriceOracle(_priceOracle);
    }

    /*function checkBalances(address user, uint256 poolId) internal view returns(uint256){
        Pool storage pool = assets[poolId];
        if (pool.balances[user] > 0){
            return pool.balances[user];
        }else{
            return 0;
        }
    }*/

    //function deposit(address asset, uint256 amount, address onBehalfOf, uint256 referralCode) payable public{
    function deposit(uint256 poolId, uint256 amount) public payable {
        ///CEI: Checks, Effects, Interactions
        // Se verifica que el monto sea menor o igual a los fondos disponibles
        if (amount == 0) {
            revert ItCantBeZero();
        }

        if (!(balances[msg.sender] > 0)) {
            depositTimestamp[msg.sender][poolId] = uint256(block.timestamp);
        }

        updatePrincipal(poolId);

        if (poolId == 1) {
            priceFeedBTC_ETH = priceOracle.getBTC_ETHPrice();
            uint256 amountAToken = amount * priceFeedBTC_ETH;
            aToken.mint(msg.sender, amountAToken);
            assets[poolId].totalSupply += amount;
        }

        emit Deposit(msg.sender, amount);
        balances[msg.sender] += amount;
    }

    function balanceOf(address user) public view returns (uint256) {
        return balances[user];
    }

    function totalSupply(uint256 poolId) public view returns (uint256) {
        return assets[poolId].totalSupply;
    }

    //Como calcular actualizar los intereses? Si se llama a la funcion updatePrincipal() despues del deposit, puede pasar, por ejemplo, un año y al hacer deposit de nuevo y no se habrán actualizado los intereses. Si se usa la funcion antes del propio deposit
    function updatePrincipal(uint256 poolId) public returns (uint256) {
        uint256 timeElapsed = block.timestamp -
            depositTimestamp[msg.sender][poolId];
        if (timeElapsed > 0) {
            rate = interestRates.getInterestRate();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;

            //CUIDADO QUE SON SEGUNDOS
            uint256 interest = balances[msg.sender] * rate * timeElapsed;
            balances[msg.sender] += interest;
            depositTimestamp[msg.sender][poolId] = block.timestamp;
        }
        return balances[msg.sender];
    }

    function withdraw(uint256 poolId, uint256 amount) public {
        updatePrincipal(poolId);

        ///CEI: Checks, Effects, Interactions

        // Se verifica que el monto sea menor o igual a los fondos disponibles, en caso contrario se cancela la transaccion
        if (amount > balances[msg.sender]) {
            revert InsufficientFunds();
        }
        // Se queman tokens aToken del usuario
        aToken.burn(msg.sender, amount);

        // Se llama a la función permit para permitir el gasto desde el contrato
        //aToken.permit(address(this), msg.sender, amount, deadline, v, r, s);
        aToken.permit(
            address(this),
            msg.sender,
            amount,
            0,
            0,
            bytes32(0),
            bytes32(0)
        );

        // Se actualiza los balances y el suministro total
        balances[msg.sender] -= amount;
        assets[poolId].totalSupply -= amount;

        //Se emite la notificacion del evento
        emit Withdraw(msg.sender, amount);

        // Se realiza la transferencia de tokens desde el contrato al usuario
        bool sent = aToken.transferFrom(address(this), msg.sender, amount);
        require(sent, "Wihtdraw failed");
    }

    //function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {
    function borrow(uint256 poolId, uint256 amount) public {
        if (debt[msg.sender] > 0) revert YouAlreadyHaveDebt();
        updateBorrow(poolId);
        borrowTimestamp[msg.sender][poolId] = block.timestamp;

        if (balances[msg.sender] > amount * 125 * 10 ** 16) {
            //collateral[msg.sender]+=amount*125/100;
            collateral[msg.sender] += amount * 125 * 10 ** 16;
            //asset[msg.sender]-=amount*125/100;
            emit Borrow(msg.sender, amount);
            balances[msg.sender] -= amount * 125 * 10 ** 16;
            debt[msg.sender] += amount;
            assets[poolId].totalSupply -= amount;

            //payable[msg.sender].transferFrom(msg.sender, address(this),amount);
            //aTokenDebt.permit(address(this), msg.sender, amount, deadline, v, r, s);
            aTokenDebt.permit(
                address(this),
                msg.sender,
                amount,
                0,
                0,
                bytes32(0),
                bytes32(0)
            );
            //CUIDADO QUE SON TOKENS; NO ETHER
            bool sent = aTokenDebt.transferFrom(
                address(this),
                msg.sender,
                amount
            );
            require(sent, "Borrow failed");
        }
    }

    function updateBorrow(uint256 poolId) public returns (uint256) {
        uint256 timeElapsed = block.timestamp -
            borrowTimestamp[msg.sender][poolId];
        if (timeElapsed > 0) {
            rate = interestRates.getInterestBorrow();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = debt[msg.sender] * rate * timeElapsed; //CUIDADO, SON SEGUNDOS
            debt[msg.sender] += interest;
            borrowTimestamp[msg.sender][poolId] = block.timestamp;
        }
        return debt[msg.sender];
    }

    function repay(uint256 poolId, uint256 amount) public payable {
        updateBorrow(poolId);

        if (debt[msg.sender] < amount) {
            revert DebtIsLower();
        }
        emit Repay(msg.sender, amount);
        debt[msg.sender] -= amount;
        collateral[msg.sender] -= amount * 125 * 10 ** 16;
        aTokenDebt.burn(msg.sender, amount);
        balances[msg.sender] += amount * 125 * 10 ** 16;
        //NECESITO APPROVE??
        //msg.sender.transferFrom(address(this),msg.sender,amount);
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
