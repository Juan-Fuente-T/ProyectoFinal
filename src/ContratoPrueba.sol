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

    
    struct Borrow{
        uint256 idBorrow;
        uint256 poolId;
        uint256 userDebt;
        uint256 amountCollateral;
    }

    mapping(uint256 => Pool)assets;
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(address => Borrow[]) borrows;
    //mapping(address => Borrow) borrows;

    function createPool(uint256 _poolId, uint256 _initialSupply) public {
        Pool storage pool = assets[_poolId];
        pool.poolId = _poolId;
        pool.totalSupply = _initialSupply;
    }
    IaToken public weth;
    IaToken public wbtc;
    IaToken public wlink;
    IaToken public wusdt;
    IaToken public wada;
    AToken public aToken;

    address owner;
    uint256 LTV = 75 * 10 ** 16;
    uint256 amount;
    uint256 amountCollateral;

    error NotApproved();
    error MintFailed();
    error TransferFailed();
    error ItCantBeZero();
    constructor(){

        //weth = IaToken(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);//variante weth
        weth = IaToken(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9); //funciona bien ? weth?
        //weth = IaToken(0x6F03999B2CC712570e75c73432328B1B669716d1);
        //aToken = IaToken(0x35AAd3fD9fe3a8F1897a119fc5DaF34FB6cF4B62);
        //wbtc = IaToken(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        wbtc = IaToken(0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC);
        
        wlink = IaToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        wusdt = IaToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        wada = IaToken(0x56694577564FdD577a0ABB20FE95C1E2756C2a11);
        //wada = IaToken(address (new aTokenAda()));
       
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

    function totalSupply(uint256 poolId) public view returns(uint256){
        return assets[poolId].totalSupply;
}
    function deposit(uint256 poolId, uint256 _amount) public{
        
        assets[poolId].totalSupply += _amount;
        balances[msg.sender][poolId] += _amount;

        ///CEI: Checks, Effects, Interactions
        // Se verifica que el monto sea menor o igual a los fondos disponibles
        

        if (!(_amount > 0)){
            revert ItCantBeZero();
        }

       
        
        /*(bool approved) = aToken.approve(msg.sender, amount);
        if (!approved){
            revert NotApproved();
        }
        aToken.mint(msg.sender, amount);*/       
        if (poolId == 0){
            
            // Convertir ETH a wETH
            //weth.deposit{value: msg.value}();
            //amountAToken = amount;
            aToken.mint(msg.sender, _amount);

            (bool approved) = weth.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();
            }
            //aToken.permit(owner, msg.sender, amount, block.timestamp + 30, 0, bytes32(0), bytes32(0));
            //aToken.userBalance(msg.sender);
            (bool success) = weth.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        else if (poolId == 1){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aToken.mint(msg.sender, _amount);

            (bool approved) = wbtc.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wbtc.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
    }
    function withdraw(uint256 poolId, uint256 _amount) public{


        assets[poolId].totalSupply -= _amount;
        balances[msg.sender][poolId] -= _amount;
        


        //weth.approve(address(this), _amount);
        /*(bool approved) = weth.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
        if (poolId == 0){      

            aToken.burn(msg.sender, _amount);

            (bool success) = weth.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }    

        if (poolId == 1){
            aToken.burn(msg.sender, _amount);

            (bool success) = wbtc.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }
    }
    

        function balanceOf(address, uint256 poolId) public view returns (uint256){
        return balances[msg.sender][poolId];
    }

    function borrow(uint256 idBorrow, uint256 poolId, uint256 _amount) public {
    amountCollateral = _amount;
    uint256 userDebt = _amount * 75 / 100;
  
        assets[poolId].totalSupply -= userDebt;
        balances[msg.sender][idBorrow] -= amountCollateral;
        borrows[msg.sender].push(Borrow(idBorrow, poolId, userDebt, amountCollateral));
 
        if (poolId == 0){
            /*(bool approved) = aTokenDebt.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }*/
            aToken.mint(msg.sender, amount);

            (bool success) = weth.transfer(msg.sender, amount);
                if(!success){
                    revert TransferFailed();
                }
        }      
        if (poolId == 1){
 
            aToken.mint(msg.sender, amount);

            (bool success) = wbtc.transfer(msg.sender, amount);
                if(!success){
                    revert TransferFailed();
                }
        }
    } 

    function getBorrowPoolId(address user, uint256 IdBorrow) public view returns (uint256) {
        require(IdBorrow < borrows[user].length, "Invalid borrow index");
        return borrows[user][IdBorrow].poolId;
    }


    function repay(uint256 idBorrow, uint256 _amount)payable public {
        amountCollateral = _amount / LTV;
        amount = _amount;

        require(borrows[msg.sender].length > 0, "No active loans to repay");
        uint256 poolId = getBorrowPoolId(msg.sender, idBorrow);
    
        assets[poolId].totalSupply += amount;
        balances[msg.sender][idBorrow] += amountCollateral;
        borrows[msg.sender][idBorrow].userDebt -= amount;
        borrows[msg.sender][idBorrow].amountCollateral -= amountCollateral;
 

        if (idBorrow == 0){
            aToken.burn(msg.sender, amount);

            (bool approved) = weth.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            
            (bool success) = weth.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }

        }
        if (idBorrow == 1){
            //iwbtc._burn(msg.sender, amount);
            aToken.burn(msg.sender, amount);

            (bool approved) = wbtc.approve(address(this), amount);
            if (!approved){
                revert NotApproved();
            }
            
            (bool success) = wbtc.transferFrom(msg.sender, address(this), amount);
            if(!success){
                revert TransferFailed();
            }
        }
    }
}
