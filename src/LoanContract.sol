// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import {ERC20} from "./libraries/ERC20.sol";
//import {AggregatorV3Interface} from "./libraries/AggregatorV3Interface.sol";
import {AToken} from "./aToken.sol";
import {ATokenDebt} from "./aTokenDebt.sol";
import { InterestRates } from "./InterestRates-copia.sol";
import { PriceOracle } from "./PriceOracle-copia.sol";
import { IWETH } from "../src/libraries/IWETH.sol";
import {LendingPool} from "./LendingPool - copia.sol";

interface ICombinedToken{
    function mint(address user, uint256 amount) external; 
    function burn(address user, uint256 amount) external;
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
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

contract LoanContract{
    address owner;
    ICombinedToken public aToken;
    ICombinedToken public aTokenDebt;
    IWETH public weth;
    uint256 rate;
    uint256 LTV = 75 * 10 ** 16;
    uint256 amountAToken;
    uint256 amount;
    uint256 amountCollateral;

    uint256 priceFeedETH_BTC;
    uint256 priceFeedBTC_ETH;
    uint256 priceFeedLINK_ETH;
    uint256 priceFeedETH_LINK;
    uint256 priceFeedUSDT_ETH;
    uint256 priceFeedETH_USDT;
    uint256 priceFeedADA_ETH;
    uint256 priceFeedETH_ADA;

    InterestRates public immutable interestRates;
    PriceOracle public immutable priceOracle;
    LendingPool public lendingPool;

    mapping(address => mapping(uint256 => uint256)) borrowTimestamp;
        constructor(PriceOracle _priceOracle, InterestRates _interestRates, LendingPool _lendingPool){
        priceOracle = PriceOracle(_priceOracle);
        interestRates = InterestRates(_interestRates);
        lendingPool = LendingPool(_lendingPool);
        owner = msg.sender;           
    }

    

    function borrow(address user, uint256 idBorrow, uint256 poolId, uint256 _amount, uint256 _amountCollateral) public {
        amount = _amount;
        amountCollateral = _amountCollateral * 10**18;
        /*if (debt[msg.sender][idBorrow] > 0) {
            borrowTimestamp[msg.sender][idBorrow] = block.timestamp;
            revert YouAlreadyHaveDebt();
        }*/
            //lendingPool.setTotalSupply(0, 3000);
            //lendingPool.increaseCollateral(msg.sender, idBorrow, poolId, amountCollateral);
            //lendingPool.decreaseBalanceOf(msg.sender,poolId, amountCollateral);
            //lendingPool.increaseDebt(msg.sender,idBorrow, poolId,amount);
                        


        if (poolId == 0) {
            
    
            

                //updateBorrow(poolId);
                // Se realiza la transferencia de tokens desde el contrato al usuario
                // bool sent = weth.transfer(msg.sender, amount);
                // require(sent, "Withdraw failed");
                // collateral[msg.sender] += amount * 125 * 10**16;


                // asset[msg.sender] -= amount * 125 * 10**16;
                // aTokenDebt.mint(msg.sender, amountAToken);
                // payable[msg.sender].transferFrom(msg.sender, address(this), amount);
                // aTokenDebt.permit(address(this), msg.sender, amount, deadline, v, r, s);
                // aTokenDebt.permit(address(this), msg.sender, amount, 0, 0, bytes32(0), bytes32(0));
                // CUIDADO QUE SON TOKENS; NO ETHER
                // bool sent = aTokenDebt.transferFrom(address(this), msg.sender, amount);

                // require(sent, "Borrow failed");
            }

            /*if (poolId == 1) {
                //updateBorrow(poolId);
                // Se realiza la transferencia de tokens desde el contrato al usuario
                // bool sent = weth.transfer(msg.sender, amount);
                // require(sent, "Withdraw failed");
                // collateral[msg.sender] += amount * 125 * 10**16;
                priceFeedBTC_ETH = priceOracle.testGetBTC_ETHPrice();
                amountCollateral = amount * priceFeedBTC_ETH * 125/100;
                if (lendingPool.balanceOf(msg.sender,poolId) > amountCollateral) {
                    lendingPool.increaseCollateral(msg.sender, idBorrow, poolId, amountCollateral);
                    lendingPool.decreaseBalanceOf(msg.sender,poolId, amountCollateral);
                    lendingPool.increaseDebt(msg.sender,idBorrow,poolId, amount);
                }
                
            }*/
        }
    

    
        function updateBorrow(uint256 idBorrow,uint256 poolId) public returns(uint256){
        
        uint256 timeElapsed = block.timestamp - borrowTimestamp[msg.sender][poolId];
        if(timeElapsed > 0){
            rate = interestRates.getInterestBorrow();
            //ASI o asi?: uint256 interest = principal * interestRate / timeElapsed;
            uint256 interest = rate * timeElapsed; //CUIDADO, SON SEGUNDOS
            lendingPool.getDebt(msg.sender, idBorrow) * interest;
            borrowTimestamp[msg.sender][poolId] = block.timestamp;
            return lendingPool.getDebt(msg.sender, idBorrow) * interest;  
        }
    }
}

