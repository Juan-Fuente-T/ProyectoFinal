// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./aToken.sol";
import { ERC20 } from "./libraries/ERC20.sol";



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

contract PruebaLendingPool{


    struct Pool{
        uint256 poolId;
        uint256 totalSupply;
    }

    mapping(uint256 => Pool)assets;
    mapping(address => uint256) balances;

    function createPool(uint256 _poolId, uint256 _initialSupply) public {
        Pool storage pool = assets[_poolId];
        pool.poolId = _poolId;
        pool.totalSupply = _initialSupply;
    }
    IaToken public weth;
    AToken public aToken;

    address owner;

    error NotApproved();
    error MintFailed();
    error TransferFailed();

    constructor(){

        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
        //weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        //aToken = IaToken(0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62);

        aToken = new AToken();
        
        owner = msg.sender;

        createPool(0, 100000000000000000000);
        createPool(1, 100000000000000000000);
        createPool(2, 1000000000000000000000);
        createPool(3, 10000000000000000000000);
        createPool(4, 1000000000000000000000);   
    }

        function setOwner(address newOwner) public {
        owner = newOwner;
    }

    function deposit(uint256 poolId, uint256 _amount) public{
        uint256 amount = _amount;
        assets[poolId].totalSupply += amount;
        balances[msg.sender] += amount;

        aToken.mint(msg.sender, amount);
        
        (bool approved) = weth.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            
        (bool success) = weth.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }

    }
    
    function withdraw(uint256 poolId, uint256 amount) public{
        assets[poolId].totalSupply -= amount;
        balances[msg.sender] -= amount;
        
        aToken.burn(msg.sender, amount);
    }
    

        function balanceOf(address, uint256 poolId) public view returns (uint256){
        return balances[msg.sender];
    }
}