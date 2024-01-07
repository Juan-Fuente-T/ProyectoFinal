// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./libraries/aToken.sol";
import {ATokenDebt} from "./libraries/aTokenDebt.sol";
import {DataConsumerV3} from "../src/DataFeeds.sol";
import "./libraries/SafeMath.sol";
import {console} from "forge-std/console.sol";

interface IERC20 {
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

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function getAllowance(
        address _owner,
        address spender
    ) external view returns (uint256);

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
    using SafeMath for uint256;

    struct Pool {
        uint256 totalSupply;
        uint256 totalDebt;
        address underlying; //token subyacente
        address aToken;
        address aTokenDebt;
    }

    struct Loan {
        uint64 loanCounter;
        uint64 poolIdCollateral;
        uint64 poolIdDebt;
        bool active;
        uint256 amountCollateral;
        uint256 userDebt;
        uint256 timestamp;
    }

    address owner;
    uint256 rate;
    uint256 userDebt;
    uint256 public loanToValue;
    uint128 _poolId;
    uint64 loanCounter;

    mapping(address => mapping(uint256 => Loan)) public userLoans;
    mapping(uint256 => Pool) public pools;
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(address => mapping(uint256 => uint256)) depositTimestamp;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    function createPool(
        uint128 _initialSupply,
        address _underlying,
        address _aToken,
        address _aTokenDebt
    ) public onlyOwner {
        Pool storage pool = pools[_poolId];
        pool.totalSupply = _initialSupply;
        pool.underlying = _underlying;
        pool.aToken = _aToken;
        pool.aTokenDebt = _aTokenDebt;

        _poolId++;
    }

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
    DataConsumerV3 public dataConsumerV3;

    error NotApproved();
    error MintFailed();
    error TransferFailed();
    error ItCantBeZero();
    error DebtDontExist();
    error InsufficientFunds();
    error InsufficientCollateral();
    error RepaymentExceedsDebt();
    error ArithmeticOverflow();

    /*error DebtIsLower();
    error YouAlreadyHaveDebt();*/

    event Deposit(address indexed user, uint256 amount, address underlying);
    event Withdraw(address indexed user, uint256 amount, address underlying);
    event Borrow(address indexed user, uint256 amount, address underlying);
    event Repay(address indexed user, uint256 amount, address underlying);

    constructor() {
        owner = msg.sender;
        aTokenEth = new AToken("ReplicaAaveTokenEth", "ATKETH", 18);
        aTokenBtc = new AToken("ReplicaAaveTokenBtc", "ATKBTC", 18);
        aTokenLink = new AToken("ReplicaAaveTokenLink", "ATKLINK", 18);
        aTokenUsdt = new AToken("ReplicaAaveTokenUsdt", "ATKUSDT", 18);
        aTokenDai = new AToken("ReplicaAaveTokenDai", "ATKDAI", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebtEth", "DETH", 18);
        aTokenDebtBtc = new ATokenDebt("ReplicaAaveTokenDebBtc", "DBTC", 18);
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
        dataConsumerV3 = new DataConsumerV3();
        createPool(
            100000 * 1e18,
            0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
            address(aTokenEth),
            address(aTokenDebtEth)
        );
        createPool(
            100000 * 1e18,
            0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC,
            address(aTokenBtc),
            address(aTokenDebtBtc)
        );
        //createPool(2, 1000 ether, 0x779877A7B0D9E8603169DdbD7836e478b4624789, address(aTokenLink));//Buena?ADRI
        //createPool(2, 1000 ether, 0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, address(aTokenLink));
        createPool(
            19999999999999 * 1e18,
            0xf531B8F309Be94191af87605CfBf600D71C2cFe0,
            address(aTokenLink),
            address(aTokenDebtLink)
        ); //prueba btc
        //createPool(3, 10000 ether, 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06, address(aTokenUsdt));//Buena?ADRI
        //createPool(2000000 ether, 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, address(aTokenUsdt), address(aTokenDebtUsdt));//prueba btc
        createPool(
            100000000000000 * 1e18,
            0x74540605Dc99f9cd65A3eA89231fFA727B1049E2,
            address(aTokenUsdt),
            address(aTokenDebtUsdt)
        ); //prueba OTRA Usdc
        createPool(
            100000000000000 * 1e18,
            0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6,
            address(aTokenDai),
            address(aTokenDebtDai)
        ); //DAI
    }

    /*function createLoan(uint64 poolIdCollateral, uint64 poolIdDebt, uint256 userDebt, uint256 _amountCollateral, uint128 _loanCounter) public {
        Loan storage loan = userLoans[msg.sender][_loanCounter];
        loan.poolIdCollateral = poolIdCollateral;
        loan.poolIdDebt = poolIdDebt;
        loan.amountCollateral = _amountCollateral;
        loan.userDebt = userDebt;
        loan.active = true;
    }*/

    function setOwner(address newOwner) public {
        owner = newOwner;
    }

    function getConvertedValue(
        uint256 coin1,
        uint256 coin2
    ) public view returns (uint256) {
        //da el valor de la primera moneda en la segunda, por ejemplo 1 btc son 18 eth
        uint256 coin1ValueinUSD = getDataFeed(coin1);
        uint256 coin2ValueinUSD = getDataFeed(coin2);

        if (coin1ValueinUSD == 0) {
            // Manejar el caso en el que no se puede obtener el valor de la primera moneda
            revert("Error: No se puede obtener el valor de la primera moneda");
        }
        if (coin2ValueinUSD == 0) {
            // Manejar el caso en el que no se puede obtener el valor de la segunda moneda
            revert("Error: No se puede obtener el valor de la segunda moneda");
        }
        // Realizar la conversión solo si ambos valores son distintos de cero
        uint256 convertedValue = (coin1ValueinUSD * 1e18) / coin2ValueinUSD;

        return convertedValue;
    }

    function getDataFeed(uint256 coinId) public view returns (uint256) {
        int256 conversion = dataConsumerV3.getChainlinkDataFeedLatestAnswer(
            coinId
        );
        uint256 conversionUnsigned = uint256(conversion);
        return conversionUnsigned * 1e18;
    }

    function getLoanCounter() public view returns (uint128) {
        return loanCounter;
    }

    function getLoanToValue() public view returns (uint256) {
        return loanToValue;
    }

    /*
    //ESTA FUNCION ES UTIL MAS ALLA DE TEST??
    function getAmount() public pure returns (uint256) {
        return (10 ether * 75) / 100; //resultado 7.5e18 (7.5 ether)
    }

    //ESTA FUNCION ES UTIL??
    function getAmountCollateral() public pure returns (uint256) {
        //return amountCollateral;
        //return 7.5 ether / LTV *10**18; //resuktado 1e19 (10 ether)
        return (7.5 ether * 100) / 75;
    }
*/
    function getUnderlying(uint64 poolId) public view returns (address) {
        return pools[poolId].underlying;
    }

    function totalSupply(uint64 poolId) public view returns (uint256) {
        return pools[poolId].totalSupply;
    }

    function totalDebt(uint64 poolId) public view returns (uint256) {
        return pools[poolId].totalDebt;
    }

    function balanceOf(address, uint64 poolId) public view returns (uint256) {
        return balances[msg.sender][poolId];
    }

    function getPoolIdDebt(uint128 _loanCounter) public view returns (uint64) {
        return userLoans[msg.sender][_loanCounter].poolIdDebt;
    }

    function getPoolIdCollateral(
        uint128 _loanCounter
    ) public view returns (uint64) {
        return userLoans[msg.sender][_loanCounter].poolIdCollateral;
    }

    function getUserCollateral(
        uint128 _loanCounter
    ) public view returns (uint256) {
        return userLoans[msg.sender][_loanCounter].amountCollateral;
    }

    function getUserDebt(
        address user,
        uint128 _loanCounter
    ) public view returns (uint256) {
        return userLoans[user][_loanCounter].userDebt;
    }

    function updatePrincipal(uint128 poolId) public returns (uint256) {
        if (balances[msg.sender][poolId] == 0) {
            depositTimestamp[msg.sender][poolId] = uint128(block.timestamp);
        }
        uint256 timeElapsed = block.timestamp -
            depositTimestamp[msg.sender][poolId];
        if (timeElapsed > 0) {
            //rate = interestRates.getInterestRate();

            //5 / (btc prestado) / (btc depositado)
            rate =
                (5 / (pools[poolId].totalDebt)) /
                (pools[poolId].totalSupply);
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

    function updateBorrow(
        uint64 poolIdDebt,
        uint128 _loanCounter
    ) public returns (uint256) {
        if (userLoans[msg.sender][_loanCounter].userDebt == 0) {
            userLoans[msg.sender][_loanCounter].timestamp = block.timestamp;
        }

        uint256 timeElapsed = block.timestamp -
            userLoans[msg.sender][_loanCounter].timestamp;
        if (timeElapsed > 0) {
            //rate = interestRates.getInterestBorrow();
            rate =
                (5 / (pools[poolIdDebt].totalDebt)) /
                (pools[poolIdDebt].totalSupply);
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = getUserDebt(msg.sender, _loanCounter) *
                (rate / (365 * 24 * 60 * 60)) *
                timeElapsed; //CUIDADO, SON SEGUNDOS
            userLoans[msg.sender][_loanCounter].userDebt += interest;
            userLoans[msg.sender][_loanCounter].timestamp = block.timestamp;
        }
        return userLoans[msg.sender][_loanCounter].userDebt;
    }

    function deposit(uint64 poolId, uint256 _amount) public {
        ///CEI: Checks, Effects, Interactions
        updatePrincipal(poolId);

        if (_amount == 0) {
            revert ItCantBeZero();
        }

        IERC20(pools[poolId].aToken).mint(msg.sender, _amount);

        if (pools[poolId].totalSupply + _amount < pools[poolId].totalSupply) {
            revert ArithmeticOverflow();
        }

        if (
            balances[msg.sender][poolId] + _amount <
            balances[msg.sender][poolId]
        ) {
            revert ArithmeticOverflow();
        }

        pools[poolId].totalSupply = pools[poolId].totalSupply.add(_amount);
        balances[msg.sender][poolId] = balances[msg.sender][poolId].add(
            _amount
        );
        bool approved = IERC20(pools[poolId].underlying).approve(
            address(this),
            _amount
        );

        if (!approved) {
            revert NotApproved();
        }

        bool success = IERC20(pools[poolId].underlying).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (!success) {
            revert TransferFailed();
        }
        emit Deposit(msg.sender, _amount, pools[poolId].underlying);
    }

    function withdraw(uint64 poolId, uint256 _amount) public {
        ///CEI: Checks, Effects, Interactions
        updatePrincipal(poolId);

        if (_amount > balances[msg.sender][poolId]) {
            revert InsufficientFunds();
        }

        IERC20(pools[poolId].aToken).burn(msg.sender, _amount);

        pools[poolId].totalSupply -= _amount;
        balances[msg.sender][poolId] -= _amount;

        bool success = IERC20(pools[poolId].underlying).transfer(
            msg.sender,
            _amount
        );
        if (!success) {
            revert TransferFailed();
        }
        emit Withdraw(msg.sender, _amount, pools[poolId].underlying);
    }

    function borrow(
        uint64 poolIdCollateral,
        uint64 poolIdDebt,
        uint256 _amount
    ) public {
        ///CEI: Checks, Effects, Interactions
        updateBorrow(poolIdDebt, loanCounter);

        if (balances[msg.sender][poolIdCollateral] < _amount) {
            revert InsufficientCollateral();
        }
        uint256 convertedValue = getConvertedValue(
            poolIdCollateral,
            poolIdDebt
        );
        //uint256 value = convertedValue / 1e18;
        //uint256 value = convertedValue;
        // loanToValue = ((convertedValue * 7500) / 10000);
        //loanToValue = ((value.mul(7500)) / 10000); //mul = multiplicaion
        //userDebt = _amount.mul(loanToValue);
        //userDebt = ((_amount * loanToValue) / 1e18);
        //userDebt = _amount * loanToValue;

        loanToValue = convertedValue.mul(7500).div(10000);
        userDebt = _amount.mul(loanToValue).div(1e18);
        //userDebt = _amount.div(loanToValue);

        console.log("ConvertedValue", convertedValue);
        //console.log("value", value);
        console.log("loanToValue", loanToValue);
        console.log("userDebt", userDebt);

        userLoans[msg.sender][loanCounter].loanCounter = loanCounter;
        userLoans[msg.sender][loanCounter].poolIdCollateral = poolIdCollateral;
        userLoans[msg.sender][loanCounter].poolIdDebt = poolIdDebt;
        userLoans[msg.sender][loanCounter].amountCollateral += _amount;
        userLoans[msg.sender][loanCounter].userDebt += userDebt;
        userLoans[msg.sender][loanCounter].active = true;

        pools[poolIdDebt].totalDebt += userDebt;

        balances[msg.sender][poolIdCollateral] -= _amount;

        loanCounter++;

        IERC20(pools[poolIdDebt].aToken).mint(msg.sender, userDebt);

        console.log("userDebtaTransferir", userDebt);
        console.log("CantidadqueHAY:", totalSupply(poolIdDebt));

        require(
            userDebt <= totalSupply(poolIdDebt),
            "Insufficient supply of tokens"
        );

        bool success = IERC20(pools[poolIdDebt].underlying).transfer(
            msg.sender,
            userDebt
        );
        if (!success) {
            revert TransferFailed();
        }

        emit Borrow(msg.sender, userDebt, pools[poolIdDebt].underlying);
    }

    //COMPROBAR SI HAY UNDERFLOW AL REPAGAR MAS DE LO QUE SE DEBE
    function repay(
        uint64 poolIdDebt,
        uint64 poolIdCollateral,
        uint256 _amount,
        uint128 _loanCounter
    ) public payable {
        updateBorrow(poolIdDebt, _loanCounter);

        if (!(userLoans[msg.sender][_loanCounter].active == true)) {
            revert DebtDontExist();
        }

        if (_amount > userLoans[msg.sender][_loanCounter].userDebt) {
            revert RepaymentExceedsDebt();
        }
        uint256 convertedValue = getConvertedValue(
            poolIdDebt,
            poolIdCollateral
        );

        uint256 collateral = (_amount / 7500) * 10000;
        uint256 amountCollateral = (convertedValue * collateral) / 1e18;

        userLoans[msg.sender][_loanCounter].userDebt -= _amount;
        userLoans[msg.sender][_loanCounter]
            .amountCollateral -= amountCollateral;

        if (userLoans[msg.sender][_loanCounter].userDebt == 0) {
            userLoans[msg.sender][_loanCounter].active = false;
        }

        pools[poolIdDebt].totalDebt -= _amount;

        balances[msg.sender][poolIdCollateral] += amountCollateral;

        IERC20(pools[poolIdDebt].aToken).burn(msg.sender, _amount);

        bool approved = IERC20(pools[poolIdDebt].underlying).approve(
            address(this),
            _amount
        );
        uint256 allowance = IERC20(pools[poolIdDebt].underlying).getAllowance(
            msg.sender,
            address(this)
        );
        if (!approved || allowance < _amount) {
            revert NotApproved();
        }

        bool success = IERC20(pools[poolIdDebt].underlying).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (!success) {
            revert TransferFailed();
        }

        emit Repay(msg.sender, _amount, pools[poolIdDebt].underlying);
    }
}

/**

    function borrow(
        uint64 poolIdCollateral,
        uint64 poolIdDebt,
        uint256 _amount
    ) public {
        ///CEI: Checks, Effects, Interactions
        updateBorrow(poolIdDebt, loanCounter);

        if (balances[msg.sender][poolIdCollateral] < _amount) {
            revert InsufficientCollateral();
        }
        uint256 convertedValue = getConvertedValue(
            poolIdCollateral,
            poolIdDebt
        );
        uint256 value = convertedValue / 1e18;
        //uint256 loanToValue = ((convertedValue * 7500) / 10000);
        uint256 loanToValue = ((value * 7500) / 10000);
        userDebt = _amount.mul(loanToValue);
        //userDebt = ((_amount * loanToValue) / 1e18);
        //userDebt = _amount * loanToValue;

        userLoans[msg.sender][loanCounter] = Loan({
            loanCounter: loanCounter,
            poolIdCollateral: poolIdCollateral,
            poolIdDebt: poolIdDebt,
            active: true,
            amountCollateral: _amount,
            userDebt: userDebt,
            timestamp: block.timestamp
        });

        pools[poolIdDebt].totalDebt += userDebt;

        balances[msg.sender][poolIdCollateral] -= _amount;

        loanCounter++;

        IERC20(pools[poolIdDebt].aToken).mint(msg.sender, userDebt);

        bool success = IERC20(pools[poolIdDebt].underlying).transfer(
            msg.sender,
            userDebt
        );
        if (!success) {
            revert TransferFailed();
        }

        emit Borrow(msg.sender, userDebt, pools[poolIdDebt].underlying);
    }

 */
