// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LendingPoolAddressesProvider{
    //metodos
    function getMarketId() //devuelve un string con el Id

    function getLendingPool() //devuelve la direccipon de la lending pool asociada

    function getLendingPoolConfigurator() 
    //devuelve la direccion del LendingPoolConfigurator asociado
    
    function getLendingPoolCollateralManager()
    //devuelve el LendingPoolCollateralManagr asociado

    function gelPoolAdmin() //devuelve la direccion del pool admin

    function getPoolEmergencyAdmin()
    //devuelve la direccion del PoolEmergencyAdmin
    
    function getPriceOracle() //devuelve el oraculo de precios

    function getLendingRateOracle()
    //devuelve la direccion del LendingRateOracle
    
    function getAddress(bytes32 id) //devuelve la direccion asociada al id

}