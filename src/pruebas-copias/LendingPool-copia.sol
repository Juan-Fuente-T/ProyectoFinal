// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//ADDRESS DEPLOY Pruebas LendingPool Sepolia 0xC98B70f92e5511dC2acDa6f2BAadA4ed5ec3A786
//wrapped ether sepolia bueno: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "../aToken.sol";
import {ATokenDebt} from "../aTokenDebt.sol";
import {InterestRates} from "./InterestRates-copia.sol";
import {PriceOracle} from "./PriceOracle-copia.sol";
import {IWETH} from "../libraries/IWETH.sol";
import {LoanContract} from "./LoanContract.sol";
import {ERC20} from "../libraries/ERC20.sol";
import {SafeMath} from "../libraries/SafeMath.sol";
import {ATokenEth} from "../libraries/wETH.sol";
import {ATokenBtc} from "../libraries/wBTC.sol";
import {ATokenLink} from "../libraries/wLINK.sol";
import {ATokenUsdt} from "../libraries/wUSDT.sol";
import {ATokenAda} from "../libraries/wADA.sol";
import {ATokenDebtEth} from "../libraries/wETHDebt.sol";
import {ATokenDebtBtc} from "../libraries/wBTCDebt.sol";
import {ATokenDebtLink} from "../libraries/wLINKDebt.sol";
import {ATokenDebtUsdt} from "../libraries/wUSDTDebt.sol";
import {ATokenDebtAda} from "../libraries/wADADebt.sol";

//mi AToken deployado en sepolia fork 0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62
//mi ATokenDebt deployado en sepolia fork 0x3049F48d4C80cBAD467B247aFAb20FfDE451d8Af
//WETH Gateway 0xD322A49006FC828F9B5B37Ab215F99B4E5caB19C

//MANEJAR Deadline de permit en la INTERFAZ del user
//EN PERMIT hay datos concretos temporalmente: deadline, v,r,sea
//QUITAR ciertas DIRECCIONES del CONSTRUCTOR, descomentar FUNCIONES
//Ojo con orden y direcciones necesarias para deploy y para onwer al desplegar

///contrato WBTC aqui https://www.alchemy.com/smart-contracts/wbtc

interface IWrappedTokenGetway {
    function depositETH(
        address pool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    function withdrawETH(address pool, uint256 amount, address to) external;
}

interface IwBTC {
    function mint(address _to, uint256 _amount) external returns (bool);

    //function burn(uint256 _value) external;
    function _burn(address _who, uint256 _value) external;

    function approve(address _spender, uint256 _value) external returns (bool);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);
}

//interface combinada para usar con aToken y aTokenDebt
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

contract LendingPool {
    using SafeMath for uint;

    struct Pool {
        uint256 poolId;
        uint256 totalSupply;
        uint256 totalDebt;
    }

    struct Borrow {
        uint256 idBorrow;
        uint256 poolId;
        uint256 userDebt;
        uint256 amountCollateral;
    }

    address owner;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;
    uint256 amountAToken;
    uint256 amount;
    uint256 amountCollateral;

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
    AToken public aToken;
    ATokenDebt public aTokenDebt;

    IaToken public weth;
    IaToken public wbtc;
    IaToken public wlink;
    IaToken public wusdt;
    IaToken public wada;

    //IWETH public weth;
    IwBTC public iwbtc;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    function createPool(
        uint256 _poolId,
        uint256 _initialSupply,
        uint256 initialDebt
    ) public onlyOwner {
        Pool storage pool = assets[_poolId];
        pool.poolId = _poolId;
        pool.totalSupply = _initialSupply;
        pool.totalDebt = initialDebt;
    }

    //SOLO PASAR ESTAS DIRECCION POR PARAMETRO PARA TEST, EN PRODUCCION SE USAN FUNCIONES PARA asignar las direcciones a los contratos importados
    //DESCOMENTAR LAS FUNCIONES
    //constructor(PriceOracle _priceOracle, InterestRates _interestRates, LoanContract _loanContract){
    constructor() {
        //weth con mi propio
        //weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9); //sepolia
        //weth = IaToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//mainnet
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        wbtc = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC); //sepolia
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);//mainnet

        //wbtc = IaToken(address (new aTokenBtc()));
        //wlink = IaToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8); //sepolia
        //wlink = IaToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);//mainnet
        //wlink = IaToken(address(new aTokenLink()));
        //wusdt = IaToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        wusdt = IaToken(0x2CA98D7C8504a1eD69619EEc527B279361c70dca); //sepolia
        //wusdt = IaToken(0xbb4e898B2fBEe432Cde5bB681be325b7e13440FF);//Mainnet
        //wusdt = IaToken(address (new aTokenUsdt()));
        //wada = IaToken(0x56694577564FdD577a0ABB20FE95C1E2756C2a11);
        wada = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923); //sepolia
        //wada = IaToken(0x9c05d54645306d4C4EAd6f75846000E1554c0360);//mainnet
        //wada = IaToken(address (new aTokenAda()));
        //aToken = IaToken(0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62);
        aTokenEth = new ATokenEth();
        aTokenBtc = new ATokenBtc();
        aTokenLink = new ATokenLink();
        aTokenUsdt = new ATokenUsdt();
        aTokenAda = new ATokenAda();
        aTokenDebtEth = new ATokenDebtEth();
        aTokenDebtBtc = new ATokenDebtBtc();
        aTokenDebtLink = new ATokenDebtLink();
        aTokenDebtUsdt = new ATokenDebtUsdt();
        aTokenDebtAda = new ATokenDebtAda();
        aToken = new AToken();
        aTokenDebt = new ATokenDebt();
        //gateway = IWrappedTokenGetway(_gateway);

        owner = msg.sender;
        createPool(0, 1000 ether, 0);
        createPool(1, 1000 ether, 0);
        createPool(2, 10000 ether, 0);
        createPool(3, 100000 ether, 0);
        createPool(4, 10000 ether, 0);
        predefinedBorrows[0] = Borrow(0, 0, 0, 0); // Se predefine un borrow para weth
        predefinedBorrows[1] = Borrow(1, 0, 0, 0); // Se predefine un borrow para wbtc
        predefinedBorrows[2] = Borrow(2, 0, 0, 0); // Se predefine un borrow para wlink
        predefinedBorrows[3] = Borrow(3, 0, 0, 0); // Se predefine un borrow para wusdt
        predefinedBorrows[4] = Borrow(4, 0, 0, 0); // Se predefine un borrow para wada
    }

    Borrow[5] public predefinedBorrows;
    mapping(address => Borrow[5]) public userBorrows;
    mapping(uint256 => Pool) assets;
    mapping(address => mapping(uint256 => uint256)) balances;
    //mapping(address => mapping(uint256 => Pool)) debt;
    //mapping(address => mapping(uint256 => Pool)) collateral;
    //mapping(address => mapping(uint256 => Borrow)) borrows;
    //mapping(uint256 => Borrow) borrows;
    //mapping(address => Borrow[]) userBorrows;
    mapping(address => mapping(uint256 => uint256)) depositTimestamp;
    mapping(address => mapping(uint256 => uint256)) borrowTimestamp;

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
    event Borrow_(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    /*function wETHTotalSupply() public returns(uint256 aTokenTotalSupply){
        return weth.totalSupply;
    }
    function wETHUserBalance(address user) public returns(uint256 aTokenTotalSupply){
        return weth.balanceOf[user];
    }*/

    function increaseTotalSupply(uint256 poolId, uint256 _amount) public {
        assets[poolId].totalSupply += _amount;
    }

    function decreaseTotalSupply(uint256 poolId, uint256 _amount) public {
        assets[poolId].totalSupply -= _amount;
    }

    function increaseTotalDebt(uint256 poolId, uint256 _amount) public {
        assets[poolId].totalDebt += _amount;
    }

    function decreaseTotalDebt(uint256 poolId, uint256 _amount) public {
        assets[poolId].totalDebt -= _amount;
    }

    /*function increaseCollateral(address user, uint256 idBorrow, uint256 _amount) public {
        borrows[user][idBorrow].amountCollateral += _amount;
    }
    function decreaseCollateral(address user, uint256 idBorrow, uint256 _amount) public {
        borrows[user][idBorrow].amountCollateral -= _amount;
    }
    function increaseDebt(address user, uint256 idBorrow, uint256 _amount) public {
        borrows[user][idBorrow].userDebt += _amount;
    }
    function decreaseDebt(address user, uint256 idBorrow, uint256 _amount) public {
        userBorrows[user][idBorrow].userDebt -= _amount;
        userBorrows[msg.sender][idBorrow] = predefinedBorrows[idBorrow];
        userBorrows[msg.sender][idBorrow].userDebt -=amount;
    }*/
    function increaseBalanceOf(
        address user,
        uint256 poolId,
        uint256 _amount
    ) public {
        balances[user][poolId] += _amount;
    }

    function decreaseBalanceOf(
        address user,
        uint256 poolId,
        uint256 _amount
    ) public {
        balances[user][poolId] -= _amount;
    }

    function getAmountCollateral() public view returns (uint256) {
        return amountCollateral;
    }

    //REVISAR SI ESTA FUNCION ES UTIL, si no hay amount y _amount
    function getAmount() public view returns (uint256) {
        return amount;
    }

    //ESTA FUNCION ES UTIL??
    function getAmountAToken() public view returns (uint256) {
        return amountAToken;
    }

    function balanceOf(address, uint256 poolId) public view returns (uint256) {
        return balances[msg.sender][poolId];
    }

    function totalSupply(uint256 poolId) public view returns (uint256) {
        return assets[poolId].totalSupply;
    }

    function getCollateral(
        address user,
        uint256 idBorrow
    ) public view returns (uint256) {
        return userBorrows[user][idBorrow].amountCollateral;
    }

    function getDebt(
        address user,
        uint256 idBorrow
    ) public view returns (uint256) {
        return userBorrows[user][idBorrow].userDebt;
    }

    //ELIMINAR esta funcion despues de los test
    function setTotalSupplyAndOthers(
        address user,
        uint256 poolId,
        uint256 cantidadTotalSupply,
        uint256 cantidadUser
    ) public {
        assets[poolId].totalSupply += cantidadTotalSupply;
        balances[user][poolId] += cantidadUser;
    }

    function deposit(uint256 poolId, uint256 _amount) public payable {
        ///CEI: Checks, Effects, Interactions
        // Se verifica que el monto sea menor o igual a los fondos disponibles

        if (!(_amount > 0)) {
            revert ItCantBeZero();
        }

        //updatePrincipal(poolId);

        increaseTotalSupply(poolId, _amount);
        //assets[poolId].totalSupply += amount;
        increaseBalanceOf(msg.sender, poolId, _amount);
        //balances[msg.sender][poolId] += amount;

        /*(bool approved) = aToken.approve(msg.sender, amount);
        if (!approved){
            revert NotApproved();
        }
        aToken.mint(msg.sender, amount);*/
        if (poolId == 0) {
            // Convertir ETH a wETH
            //weth.deposit{value: msg.value}();
            //amountAToken = amount;
            aTokenEth.mint(msg.sender, _amount);

            bool approved = weth.approve(address(this), _amount);
            if (!approved) {
                revert NotApproved();
            }
            //aToken.permit(owner, msg.sender, amount, block.timestamp + 30, 0, bytes32(0), bytes32(0));
            //aToken.userBalance(msg.sender);
            bool success = weth.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert TransferFailed();
            }
        } else if (poolId == 1) {
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aTokenBtc.mint(msg.sender, _amount);

            bool approved = wbtc.approve(address(this), _amount);
            if (!approved) {
                revert NotApproved();
            }
            /*(bool success) = wbtc.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }*/
        } else if (poolId == 2) {
            //priceFeedLINK_ETH = priceOracle.testGetLINK_ETHPrice();
            //amountAToken = amount * priceFeedLINK_ETH;
            //wlink.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            aTokenLink.mint(msg.sender, _amount);

            bool approved = wlink.approve(msg.sender, _amount);
            if (!approved) {
                revert NotApproved();
            }
            bool success = wlink.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert TransferFailed();
            }
        }
        //aTokenLink.mint(msg.sender, amount);
        else if (poolId == 3) {
            //priceFeedUSDT_ETH = priceOracle.testGetUSDT_ETHPrice();
            //amountAToken = amount * priceFeedUSDT_ETH;
            //wlink.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            aTokenUsdt.mint(msg.sender, _amount);

            bool approved = wusdt.approve(msg.sender, _amount);
            if (!approved) {
                revert NotApproved();
            }
            bool success = wusdt.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert TransferFailed();
            }
        }
        // aTokenUsdt.mint(msg.sender, amount);
        else if (poolId == 4) {
            //priceFeedADA_ETH = priceOracle.testGetADA_ETHPrice();
            //amountAToken = amount * priceFeedADA_ETH;
            //wada.permit(owner, msg.sender, amount, 30, 0, bytes32(0), bytes32(0));
            aTokenAda.mint(msg.sender, _amount);

            bool approved = wada.approve(msg.sender, _amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = wada.transferFrom(
                msg.sender,
                address(this),
                _amount
            );
            if (!success) {
                revert TransferFailed();
            }
        }

        //aToken.mint(msg.sender, amountAToken);
        emit Deposit(msg.sender, _amount);
    }

    //Como calcular actualizar los intereses? Si se llama a la funcion updatePrincipal() despues del deposit, puede pasar, por ejemplo, un año y al hacer deposit de nuevo y no se habrán actualizado los intereses. Si se usa la funcion antes del propio deposit
    function updatePrincipal(uint256 poolId) public returns (uint256) {
        if (balances[msg.sender][poolId] == 0) {
            depositTimestamp[msg.sender][poolId] = uint256(block.timestamp);
        }
        uint256 timeElapsed = block.timestamp -
            depositTimestamp[msg.sender][poolId];
        if (timeElapsed > 0) {
            //rate = interestRates.getInterestRate();
            //rate = interestRates.getInterestRate();
            rate =
                (5 / (assets[poolId].totalDebt)) /
                (assets[poolId].totalSupply);
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;

            //CUIDADO QUE SON SEGUNDOS
            //uint256 interest = balances[msg.sender][poolId] * (rate * timeElapsed);
            //uint256 interest = (balances[msg.sender][poolId]) * ((rate / (365 * 24 * 60 * 60)) * timeElapsed); //CUIDADO, SON SEGUNDOS
            uint256 interest = ((balances[msg.sender][poolId]) *
                ((rate / (365 * 24 * 60 * 60)) * timeElapsed)) / 100; //CUIDADO, SON SEGUNDOS
            balances[msg.sender][poolId] += interest;
            depositTimestamp[msg.sender][poolId] = block.timestamp;
        }
        return balances[msg.sender][poolId];
    }

    function withdraw(uint256 poolId, uint256 _amount) public {
        //updatePrincipal(poolId);

        ///CEI: Checks, Effects, Interactions

        // Se verifica que el monto sea menor o igual a los fondos disponibles, en caso contrario se cancela la transaccion
        if (_amount > balances[msg.sender][poolId]) {
            revert InsufficientFunds();
        }
        // Se queman tokens aToken del usuario
        //aToken.burn(msg.sender, amount);

        // Se llama a la función permit para permitir el gasto desde el contrato
        //aToken.permit(address(this), msg.sender, amount, deadline, v, r, s);

        decreaseBalanceOf(msg.sender, poolId, _amount);
        //balances[msg.sender][poolId] -= amount;
        decreaseTotalSupply(poolId, _amount);
        //assets[poolId].totalSupply -= amount;
        //aTokenDebt.burn(msg.sender, amountAToken);
        // Se actualiza los balances y el suministro total

        if (poolId == 0) {
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //amountAToken = amount;
            //aTokenDebt.permit(address(this), msg.sender, amount, block.timestamp + 30, 0, bytes32(0), bytes32(0));
            aTokenEth.burn(msg.sender, _amount);

            bool success = weth.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        //NO NECESITA APPROVE

        if (poolId == 1) {
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;

            aTokenBtc.burn(msg.sender, _amount);

            bool success = weth.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        //NO NECESITA APPROVE
        if (poolId == 2) {
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedLINK_ETH = priceOracle.testGetLINK_ETHPrice();
            //amountAToken = amount * priceFeedLINK_ETH;
            /*(bool approved) = wink.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenLink.burn(msg.sender, _amount);

            bool success = weth.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        //NO NECESITA APPROVE
        if (poolId == 3) {
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedUSDT_ETH = priceOracle.testGetUSDT_ETHPrice();
            //amountAToken = amount * priceFeedUSDT_ETH;
            /*(bool approved) = aTokenUsdt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenUsdt.burn(msg.sender, _amount);

            bool success = weth.transfer((msg.sender), _amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        //NO NECESITA APPROVE
        if (poolId == 4) {
            // Se realiza la transferencia de tokens desde el contrato al usuario
            //priceFeedADA_ETH = priceOracle.testGetADA_ETHPrice();
            //amountAToken = amount * priceFeedADA_ETH;
            /*(bool approved) = aTokenAda.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenAda.burn(msg.sender, _amount);

            bool success = weth.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        //Se emite la notificacion del evento
        emit Withdraw(msg.sender, _amount);
    }

    //function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)public {

    //idBorrow de donde se coge el collateral, poolId de donde se coge la debt, cantidad
    function borrow(uint256 idBorrow, uint256 poolId, uint256 _amount) public {
        //updateBorrow(idBorrow);

        require(idBorrow < 5, "Invalid idBorrow"); // Asegúrate de que el idBorrow sea válido

        //amountCollateral = amount;

        uint256 userDebt = (_amount * 75) / 100;

        userBorrows[msg.sender][idBorrow] = predefinedBorrows[idBorrow];
        userBorrows[msg.sender][idBorrow].userDebt += userDebt;
        userBorrows[msg.sender][idBorrow].amountCollateral += _amount;
        userBorrows[msg.sender][idBorrow].poolId = poolId;

        //assets[poolId].totalSupply -= userDebt;
        decreaseTotalSupply(poolId, userDebt);
        //balances[msg.sender][idBorrow] -= amountCollateral;
        decreaseBalanceOf(msg.sender, idBorrow, _amount);
        //borrows[msg.sender].push(Borrow(idBorrow, poolId, userDebt, amountCollateral));
        increaseTotalDebt(idBorrow, _amount);

        if (poolId == 0) {
            /*(bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenEth.mint(msg.sender, _amount);

            bool success = weth.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        if (poolId == 1) {
            aTokenBtc.mint(msg.sender, _amount);

            bool success = wbtc.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        if (poolId == 2) {
            /*(bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenDebtLink.mint(msg.sender, _amount);

            bool success = wlink.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        if (poolId == 3) {
            /*(bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenDebtUsdt.mint(msg.sender, _amount);

            bool success = wusdt.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        if (poolId == 4) {
            /*(bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aTokenDebtAda.mint(msg.sender, _amount);

            bool success = wada.transfer(msg.sender, _amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        emit Borrow_(msg.sender, amount);
    }

    function updateBorrow(uint256 idBorrow) public returns (uint256) {
        if (userBorrows[msg.sender][idBorrow].userDebt == 0) {
            borrowTimestamp[msg.sender][idBorrow] = block.timestamp;
        }

        uint256 timeElapsed = block.timestamp -
            borrowTimestamp[msg.sender][idBorrow];
        if (timeElapsed > 0) {
            //rate = interestRates.getInterestBorrow();
            rate =
                (5 / (assets[idBorrow].totalDebt)) /
                (assets[idBorrow].totalSupply);
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = getDebt(msg.sender, idBorrow) *
                (rate / (365 * 24 * 60 * 60)) *
                timeElapsed; //CUIDADO, SON SEGUNDOS
            userBorrows[msg.sender][idBorrow].userDebt = interest;
            borrowTimestamp[msg.sender][idBorrow] = block.timestamp;
        }
        return userBorrows[msg.sender][idBorrow].userDebt;
    }

    //En REPAY la cantidad que elige el user no es el collateral sino la deuda.
    //Se divide entre LTV para saber la cantidad de collateral y balance a aumnetar
    function repay(uint256 idBorrow, uint256 _amount) public payable {
        amountCollateral = _amount / LTV;
        amount = _amount;

        //updateBorrow(idBorrow);

        if (userBorrows[msg.sender][idBorrow].userDebt < amount) {
            revert DebtIsLower();
        }
        if (!(userBorrows[msg.sender][idBorrow].userDebt > 0)) {
            revert YouDontHaveDebt();
        }

        //decreaseDebt(msg.sender,idBorrow,amount);
        decreaseTotalDebt(idBorrow, amount);
        //decreaseCollateral(msg.sender, idBorrow, amountCollateral);
        increaseBalanceOf(msg.sender, idBorrow, amountCollateral);
        increaseTotalSupply(idBorrow, amount);

        if (idBorrow == 0) {
            aTokenDebtEth.burn(msg.sender, amount);

            bool approved = weth.approve(address(this), amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = weth.transferFrom(msg.sender, address(this), amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        if (idBorrow == 1) {
            //iwbtc._burn(msg.sender, amount);
            aTokenDebtBtc.burn(msg.sender, amount);

            bool approved = wbtc.approve(address(this), amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = wbtc.transferFrom(msg.sender, address(this), amount);
            if (!success) {
                revert TransferFailed();
            }
        }
        if (idBorrow == 2) {
            //wlink.burn(msg.sender, amount);
            aTokenDebtLink.burn(msg.sender, amount);

            bool approved = wlink.approve(address(this), amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = wlink.transferFrom(
                msg.sender,
                address(this),
                amount
            );
            if (!success) {
                revert TransferFailed();
            }
        }
        if (idBorrow == 3) {
            //wusdt.burn(msg.sender, amount);
            aTokenDebtUsdt.burn(msg.sender, amount);

            bool approved = wusdt.approve(address(this), amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = wusdt.transferFrom(
                msg.sender,
                address(this),
                amount
            );
            if (!success) {
                revert TransferFailed();
            }
        }
        if (idBorrow == 4) {
            //wada.burn(msg.sender, amount);
            aTokenDebtAda.burn(msg.sender, amount);

            bool approved = wada.approve(address(this), amount);
            if (!approved) {
                revert NotApproved();
            }

            bool success = wada.transferFrom(msg.sender, address(this), amount);
            if (!success) {
                revert TransferFailed();
            }
        }

        emit Repay(msg.sender, idBorrow);
    }
}

/* ###########################################
Cosas a hacer la desplefar el contrato
- Ver todas las dependencias de contratos al despliegue
- Descomentar funciones para dar direcciones al desplegar
- Quitar Address hardcodeada en AToken y ATokenDebt
*/
