// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./aToken.sol";
import {ATokenDebt} from "./aTokenDebt.sol";
import { ERC20 } from "./libraries/ERC20.sol";
import { ATokenEth } from "./libraries/wETH.sol";
import { ATokenBtc } from "./libraries/wBTC.sol";
import { ATokenLink } from "./libraries/wLINK.sol";
import { ATokenUsdt } from "./libraries/wUSDT.sol";
import { ATokenAda } from "./libraries/wADA.sol";
import { ATokenDebtEth } from "./libraries/wETHDebt.sol";
import { ATokenDebtBtc } from "./libraries/wBTCDebt.sol";
import { ATokenDebtLink } from "./libraries/wLINKDebt.sol";
import { ATokenDebtUsdt } from "./libraries/wUSDTDebt.sol";
import { ATokenDebtAda } from "./libraries/wADADebt.sol";



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


    Borrow[5] public predefinedBorrows;
    mapping (address => Borrow[5]) public userBorrows;

    mapping(uint256 => Pool)assets;
    mapping(address => mapping(uint256 => uint256)) balances;
    //mapping(address => Borrow[]) borrows;
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
    ATokenDebt public aTokenDebt;
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
        
        //wlink = IaToken(0x010300C2cA5F5Ce31Ae1FaB11586d7bb685805C8);//
        wlink = IaToken(0xcE4cE12Cf2c4BDF213DCaA1ACA99ECA9Cd4d7F14);// PRUEBA Variante
        //wusdt = IaToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);//usdt
        wusdt = IaToken(0x55Ef41E13CF703eA5929b1Ce117D263766519DDe);//usdt VARIANTE PRUEBA
        //wada = IaToken(0x56694577564FdD577a0ABB20FE95C1E2756C2a11);
        //wada = IaToken(0xd1f79B76d477F026e8119dF29083e3eF8192f923);//sepolia
        wada = IaToken(0x5C1A2a4808Fd0Db90eBA797254C5ef82cbfc4b8D);//sepolia PRUEBA DAI
        
        //wada = IaToken(address (new aTokenAda()));
       
        aToken = new AToken();
        aTokenDebt = new ATokenDebt();
        
        owner = msg.sender;

        
        aTokenEth = new ATokenEth();
        aTokenBtc = new ATokenBtc();
        aTokenLink = new ATokenLink();
        aTokenUsdt = new ATokenUsdt();
        aTokenAda = new ATokenAda();
        aTokenDebtEth = new ATokenDebtEth();
        aTokenDebtEth = new ATokenDebtEth();
        aTokenDebtLink = new ATokenDebtLink();
        aTokenDebtUsdt = new ATokenDebtUsdt();
        aTokenDebtAda = new ATokenDebtAda();
        
        createPool(0, 100000000000000000000);
        createPool(1, 100000000000000000000);
        createPool(2, 1000000000000000000000);
        createPool(3, 10000000000000000000000);
        createPool(4, 1000000000000000000000);
        predefinedBorrows[0] = Borrow(0, 0, 0, 0); // Se predefine un borrow para weth
        predefinedBorrows[1] = Borrow(1, 0, 0, 0); // Se predefine un borrow para wbtc
        predefinedBorrows[2] = Borrow(2, 0, 0, 0); // Se predefine un borrow para wlink
        predefinedBorrows[3] = Borrow(3, 0, 0, 0); // Se predefine un borrow para wusdt
        predefinedBorrows[4] = Borrow(4, 0, 0, 0); // Se predefine un borrow para wada
  
    }

    function setOwner(address newOwner) public {
    owner = newOwner;
}

    function getAmount() public view returns (uint256){
        //return amount;
        return 10 ether * 75 / 100; //resultado 7.5e18 (7.5 ether)
    }
    //ESTA FUNCION ES UTIL??
    function getAmountCollateral() public view returns (uint256){
        //return amountCollateral;
        //return 7.5 ether / LTV *10**18; //resuktado 1e19 (10 ether)
        return 7.5 ether *100/75;
    }

    function totalSupply(uint256 poolId) public view returns(uint256){
        return assets[poolId].totalSupply;
}

    function getIdBorrow(address user, uint256 idBorrow) public view returns(uint256){
        return userBorrows[user][idBorrow].idBorrow;
    }
    function getUserCollateral(address user, uint256 idBorrow) public view returns(uint256){
        return userBorrows[user][idBorrow].amountCollateral;
    }
    function getUserDebt(address user, uint256 idBorrow) public view returns(uint256){
        return userBorrows[user][idBorrow].userDebt;
    }

        function balanceOf(address, uint256 poolId) public view returns (uint256){
        return balances[msg.sender][poolId];
    }
        function getBorrowPoolId(address user, uint256 IdBorrow) public view returns (uint256) {
        require(IdBorrow < userBorrows[user].length, "Invalid borrow index");
        return userBorrows[user][IdBorrow].poolId;
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
            aTokenEth.mint(msg.sender, _amount);

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
            aTokenBtc.mint(msg.sender, _amount);

            (bool approved) = wbtc.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wbtc.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        else if (poolId == 2){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aTokenLink.mint(msg.sender, _amount);

            (bool approved) = wlink.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wlink.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        //wusdt falla en transfer
        else if (poolId == 3){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aTokenUsdt.mint(msg.sender, _amount);

            (bool approved) = wusdt.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wusdt.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        else if (poolId == 4){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aTokenAda.mint(msg.sender, _amount);

            (bool approved) = wada.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wada.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }

        //wusdt falla en transfer
        /*else if (poolId == 3){
            //priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
            //amountAToken = amount * priceFeedBTC_ETH;
            aTokenUsdt.mint(msg.sender, _amount);

            (bool approved) = wbtc.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wbtc.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }*/
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

            aTokenEth.burn(msg.sender, _amount);

            (bool success) = weth.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }    

        if (poolId == 1){
            aTokenBtc.burn(msg.sender, _amount);

            (bool success) = wbtc.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 2){
            aTokenLink.burn(msg.sender, _amount);

            (bool success) = wlink.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 3){
            aTokenUsdt.burn(msg.sender, _amount);

            (bool success) = wusdt.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 4){
            aTokenAda.burn(msg.sender, _amount);

            (bool success) = wada.transfer(msg.sender, _amount);
                if(!success){
                    revert TransferFailed();
                }
        }
    }
    

    function borrow(uint256 idBorrow, uint256 poolId, uint256 _amount) public {
        uint256 userDebt = _amount * 75 / 100;
        
        userBorrows[msg.sender][idBorrow] = predefinedBorrows[idBorrow];
        userBorrows[msg.sender][idBorrow].userDebt += userDebt;
        userBorrows[msg.sender][idBorrow].amountCollateral += _amount;
        userBorrows[msg.sender][idBorrow].poolId = poolId;

        assets[poolId].totalSupply -= userDebt;
        balances[msg.sender][idBorrow] -= _amount;

    /*amountCollateral = _amount;
    uint256 userDebt = _amount * 75 / 100;
  
        assets[poolId].totalSupply -= userDebt;
        balances[msg.sender][idBorrow] -= amountCollateral;
        borrows[msg.sender].push(Borrow(idBorrow, poolId, userDebt, amountCollateral));
 */
        if (poolId == 0){
            aTokenDebtEth.mint(msg.sender, userDebt);


            (bool success) = weth.transfer(msg.sender, userDebt);
                if(!success){
                    revert TransferFailed();
                }
        }      
        if (poolId == 1){
 
            aTokenDebtBtc.mint(msg.sender, userDebt);

            (bool success) = wbtc.transfer(msg.sender, userDebt);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 2){
 
            aTokenDebtLink.mint(msg.sender, userDebt);
            //wlink falla en el transfer
            (bool success) = wlink.transfer(msg.sender, userDebt);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 3){
 
            aTokenDebtUsdt.mint(msg.sender, userDebt);
            //usdtfalla en el transfer
            (bool success) = wusdt.transfer(msg.sender, userDebt);
                if(!success){
                    revert TransferFailed();
                }
        }
        if (poolId == 4){
 
            aTokenDebtAda.mint(msg.sender, userDebt);
            //Falla wada en el transfer
            (bool success) = wada.transfer(msg.sender, userDebt);
                if(!success){
                    revert TransferFailed();
                }
        }
    } 




    function repay(uint256 idBorrow, uint256 _amount)payable public {
        amountCollateral = _amount / LTV *10**18;
        

        require(userBorrows[msg.sender].length > 0, "No active loans to repay");
      
        uint256 poolId = userBorrows[msg.sender][idBorrow].poolId;
        assets[poolId].totalSupply += _amount;
        balances[msg.sender][idBorrow] += amountCollateral;
        

        userBorrows[msg.sender][idBorrow] = predefinedBorrows[idBorrow];
        userBorrows[msg.sender][idBorrow].userDebt += _amount;
        userBorrows[msg.sender][idBorrow].amountCollateral += amountCollateral;
        

        if (poolId == 0){
            aTokenDebtEth.burn(msg.sender, _amount);

            (bool approved) = weth.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();
            }
            
            (bool success) = weth.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }

        }
        if (poolId == 1){
            //iwbtc._burn(msg.sender, amount);
            aTokenDebtBtc.burn(msg.sender, _amount);

            
            (bool approved) = wbtc.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wbtc.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        
        if (poolId == 2){
            //iwbtc._burn(msg.sender, amount);
            aTokenDebtLink.burn(msg.sender, _amount);

            
            (bool approved) = wlink.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wlink.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        
        if (poolId == 3){
            //iwbtc._burn(msg.sender, amount);
            aTokenDebtUsdt.burn(msg.sender, _amount);

            
            (bool approved) = wusdt.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wusdt.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        
        if (poolId == 4){
            //iwbtc._burn(msg.sender, amount);
            aTokenDebtAda.burn(msg.sender, _amount);

            
            (bool approved) = wada.approve(address(this), _amount);
            if (!approved){
                revert NotApproved();

            }
            (bool success) = wada.transferFrom(msg.sender, address(this), _amount);
            if(!success){
                revert TransferFailed();
            }
        }
        

    }
}
