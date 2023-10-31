// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "./ERC20.sol";



contract ATokenDebtLink is ERC20{

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
    
    address public owner;
    //address public LendingPool = 0xc7183455a4C133Ae270771860664b6B7ec320bB1;
        
    error OnlyOwner();

    constructor()
        ERC20("ReplicaAaveTokenDebtLink", "DLINK", 18)
    {
        //owner = LendingPool;
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