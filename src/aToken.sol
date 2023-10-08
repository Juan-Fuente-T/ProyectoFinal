// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "./libraries/ERC20.sol";

error OnlyLendingPool();

contract AToken is ERC20{
    address public immutable lendingPool;

    constructor(address _lendingPool)
        ERC20("RéplicaAaveToken", "aToken", 18)
    {
        lendingPool = _lendingPool;
    }
    modifier onlyLendingPool(){
        if (msg.sender!= lendingPool) revert OnlyLendingPool();
        _;
    }
    
    function mint(address user, uint256 amount) 
        external
        onlyLendingPool
    {
        _mint(user, amount);
    }

    function burn(address user, uint256 amount)
        external
        onlyLendingPool
    {
        _burn(user,amount);
    }
    
}