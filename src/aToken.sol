// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "./libraries/ERC20.sol";



contract AToken is ERC20{

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
    
    address public owner;
        
    error OnlyOwner();

    constructor()
        ERC20("ReplicaAaveToken", "aToken", 18)
    {
        owner = msg.sender; // El primer owner será el que realiza el despliegue del contrato
    }


    function assignOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    function mint(address user, uint256 amount) 
        external
        onlyOwner
    {
        _mint(user, amount);
    }

    function burn(address user, uint256 amount)
        external
        onlyOwner
    {
        _burn(user,amount);
    }

    function userBalance(address user) external view returns (uint256){
        return balanceOf[user];
    }
    
}