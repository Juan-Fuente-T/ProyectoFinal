// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./libraries/aToken.sol";
import {ATokenDebt} from "./libraries/aTokenDebt.sol";

interface IERC20{
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

contract PruebaLendingPool{


    struct Pool{
        uint128 totalSupply;
        uint128 totalDebt;
        address underlying;//token subyacente
        address aToken;
        address aTokenDebt;
    }
   
    
    struct Loan{
        uint64 loanCounter;
        uint64 poolIdCollateral;
        uint64 poolIdDebt;
        uint128 amountCollateral;
        uint128 userDebt;
        bool active;
    }

    address owner;

    uint128 loanCounter;
    uint128 LTV = 75 * 10 ** 16;
    uint128 _poolId;
    //uint128 amount;
    //uint128 amountCollateral;

  
    //mapping (uint256 => Borrow) public borrowConfiguration;//ELIMINAR??
    //mapping (uint256 => Loan) public loans;
    //mapping (uint256 => mapping(uint256 => Loan)) public loans;

    mapping(address => mapping(uint256 => Loan)) public userLoans;
    mapping(uint256 => Pool)pools;
    mapping(address => mapping(uint256 => uint256)) balances;

    modifier onlyOwner (){
        require (msg.sender == owner, "Only the owner can do this");
        _;
    }
    
    function createPool(uint128 _initialSupply, address _underlying, address _aToken, address _aTokenDebt) public onlyOwner(){
    
        Pool storage pool = pools[_poolId];
        pool.totalSupply = _initialSupply;
        pool.underlying = _underlying;
        pool.aToken = _aToken;
        pool.aTokenDebt = _aTokenDebt;

        _poolId ++;
    }

    AToken public aTokenEth;
    AToken public aTokenBtc;
    AToken  public aTokenLink;
    AToken  public aTokenUsdt;
    AToken  public aTokenDai;
    ATokenDebt public aTokenDebtEth;
    ATokenDebt public aTokenDebtBtc;
    ATokenDebt public aTokenDebtLink;
    ATokenDebt public aTokenDebtUsdt;
    ATokenDebt public aTokenDebtDai;

    error NotApproved();
    error MintFailed();
    error TransferFailed();
    error ItCantBeZero();
    error DebtDontExist();
    error InsufficientFunds();
    error InsufficientCollateral();
       
    /*error DebtIsLower();
    error YouAlreadyHaveDebt();*/

    constructor(){
        /*//weth = IaToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//variante weth
        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9); //funciona bien ? weth?
        //weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        //aToken = IaToken(0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62);
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        wbtc = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);
        
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);//
        wlink = IaToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);// PRUEBA Variante
        //wusdt = IaToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);//usdt
        wusdt = IaToken(0x7169D38820dfd117C3FA1f22a697dBA58d90BA06);//usdt VARIANTE PRUEBA
        //wdai = IaToken(0x56694577564FdD577a0ABB20FE95C1E2756C2a11);ada
        //wdai = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923);//sepolia ada
        wdai = IaToken(0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6);//sepolia PRUEBA DAI
        
        //wdai = IaToken(address (new aTokenDai()));//ada*/
 
        owner = msg.sender;

        aTokenEth = new AToken("ReplicaAaveTokenEth", "ATKETH", 18);
        aTokenBtc = new AToken("ReplicaAaveTokenBtc", "ATKBTC", 18);
        aTokenLink = new AToken("ReplicaAaveTokenLink", "ATKLINK", 18);
        aTokenUsdt = new AToken("ReplicaAaveTokenUsdt", "ATKUSDT", 18);
        aTokenDai = new AToken("ReplicaAaveTokenDai", "ATKDAI", 18);
        aTokenDebtEth = new ATokenDebt("ReplicaAaveTokenDebtEth", "DETH", 18);
        aTokenDebtBtc = new ATokenDebt("ReplicaAaveTokenDebBtc", "DBTC", 18);
        aTokenDebtLink = new ATokenDebt("ReplicaAaveTokenDebtLink", "DLINK", 18);
        aTokenDebtUsdt = new ATokenDebt("ReplicaAaveTokenDebtUsdt", "DUSDT", 18);
        aTokenDebtDai = new ATokenDebt("ReplicaAaveTokenDebtDai", "DDAI", 18);
        
        createPool(1000 ether, 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9, address(aTokenEth), address(aTokenDebtEth));
        createPool(1000 ether, 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, address(aTokenBtc), address(aTokenDebtBtc));
        //createPool(2, 1000 ether, 0x779877A7B0D9E8603169DdbD7836e478b4624789, address(aTokenLink));//Buena?ADRI
        //createPool(2, 1000 ether, 0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8, address(aTokenLink));
        createPool(1000 ether, 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, address(aTokenLink), address(aTokenDebtLink));//prueba btc
        //createPool(3, 10000 ether, 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06, address(aTokenUsdt));//Buena?ADRI
        createPool(10000 ether, 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC, address(aTokenUsdt), address(aTokenDebtUsdt));//prueba btc
        createPool(10000 ether, 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6,address(aTokenDai), address(aTokenDebtDai));
       
    }

    /*function createLoan(uint64 poolIdCollateral, uint64 poolIdDebt, uint128 userDebt, uint128 _amountCollateral, uint128 _loanCounter) public {
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

    function getLoanCounter() public view returns (uint128){
        return loanCounter; 
    }

    //ESTA FUNCION ES UTIL MAS ALLA DE TEST??
    function getAmount() public pure returns (uint128){
        //return amount;
        return 10 ether * 75 / 100; //resultado 7.5e18 (7.5 ether)
    }
    //ESTA FUNCION ES UTIL??
    function getAmountCollateral() public pure returns (uint128){
        //return amountCollateral;
        //return 7.5 ether / LTV *10**18; //resuktado 1e19 (10 ether)
        return 7.5 ether *100/75;
    }
    function getUnderlying(uint64 poolId) public view onlyOwner() returns(address){
        return pools[poolId].underlying;
    }

    function totalSupply(uint64 poolId) public view returns(uint128){
        return pools[poolId].totalSupply;
    }

    function totalDebt(uint64 poolId) public view returns(uint128){
        return pools[poolId].totalDebt;
    }

    function balanceOf(address, uint64 poolId) public view returns (uint256){
        return balances[msg.sender][poolId];
    }

    function getPoolIdDebt(uint64 poolIdCollateral) public view returns (uint256) {
        return userLoans[msg.sender][poolIdCollateral].poolIdDebt;
    }

    function getPoolIdCollateral(uint64 poolIdCollateral) public view returns(uint256){
        return userLoans[msg.sender][poolIdCollateral].poolIdCollateral;
    }

    function getUserCollateral(uint64 poolIdCollateral) public view returns(uint256){
        return userLoans[msg.sender][poolIdCollateral].amountCollateral;
    }

    function getUserDebt(uint64 poolIdCollateral) public view returns(uint256){
        return userLoans[msg.sender][poolIdCollateral].userDebt;
    }


    function deposit(uint64 poolId, uint128 _amount) public{
        ///CEI: Checks, Effects, Interactions
 
        if (_amount == 0){
            revert ItCantBeZero();
        }

        IERC20(pools[poolId].aToken).mint(msg.sender, _amount);
        
        pools[poolId].totalSupply += _amount;
        balances[msg.sender][poolId] += _amount;
      
        (bool approved) = IERC20(pools[poolId].underlying).approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
        (bool success) = IERC20(pools[poolId].underlying).transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        
    }
    function withdraw(uint64 poolId, uint128 _amount) public{
        ///CEI: Checks, Effects, Interactions

        if (_amount > balances[msg.sender][poolId]){
            revert InsufficientFunds();
        }

        IERC20(pools[poolId].aToken).burn(msg.sender, _amount);

        pools[poolId].totalSupply -= _amount;
        balances[msg.sender][poolId] -= _amount;

        (bool success) = IERC20(pools[poolId].underlying).transfer(msg.sender, _amount);
            if(!success){
                revert TransferFailed();
            }
    }

    function borrow(uint64 poolIdCollateral, uint64 poolIdDebt, uint128 _amount) public {
        ///CEI: Checks, Effects, Interactions

        if (balances[msg.sender][poolIdCollateral] < _amount){
            revert InsufficientCollateral();
        }

        uint128 userDebt = _amount * 75 / 100;

        IERC20(pools[poolIdDebt].aToken).mint(msg.sender, userDebt);
        
        userLoans[msg.sender][loanCounter].poolIdCollateral = poolIdCollateral;
        userLoans[msg.sender][loanCounter].poolIdDebt = poolIdDebt;
        userLoans[msg.sender][loanCounter].amountCollateral = _amount;
        userLoans[msg.sender][loanCounter].userDebt = userDebt;
        userLoans[msg.sender][loanCounter].active = true;

        pools[poolIdDebt].totalSupply -= userDebt;
        balances[msg.sender][poolIdCollateral] -= _amount; 

        loanCounter ++;
    } 

    //COMPROBAR SI HAY UNDERFLOW AL REPAGAR MAS DE LO QUE SE DEBE
    function repay( uint64 poolIdDebt, uint64 poolIdCollateral, uint128 _amount, uint128 _loanCounter)payable public {
        uint128 amountCollateral = _amount / LTV *10**18;

        if(!(userLoans[msg.sender][_loanCounter].active == true)){
            revert DebtDontExist();
        }
        IERC20(pools[poolIdDebt].aToken).burn(msg.sender, _amount);
        
        userLoans[msg.sender][_loanCounter].userDebt -= _amount;
        userLoans[msg.sender][_loanCounter].amountCollateral -= amountCollateral;
        if(userLoans[msg.sender][_loanCounter].userDebt == 0){
            userLoans[msg.sender][_loanCounter].active = false;
        }
        pools[poolIdDebt].totalSupply += _amount;
        balances[msg.sender][poolIdCollateral] += amountCollateral; 


        /*loans[poolIdCollateral][poolIdDebt].userDebt -= _amount;
        loans[poolIdCollateral][poolIdDebt].amountCollateral -= amountCollateral;
        pools[poolIdDebt].totalSupply += _amount;
        balances[msg.sender][poolIdCollateral] += amountCollateral; */

        /*uint256 poolId = loans[idBorrow].poolId;
        pools[poolId].totalSupply += _amount;
        balances[msg.sender][idBorrow] += amountCollateral;

        //loans[idBorrow] = predefinedBorrows[idBorrow];
        loans[idBorrow].userDebt += _amount;
        loans[idBorrow].amountCollateral += amountCollateral; */   

    }
}
