contract MyContract {
    // Mock de Chainlink
    MockChainlink public mockChainlink;

    constructor(MockChainlink _mockChainlink) {
        mockChainlink = _mockChainlink;
    }

    function getDataFromChainlink() public view returns (uint256) {
        // Llamar a la función en el mock de Chainlink para obtener los datos
        return mockChainlink.getData();
    }
}

contract MockChainlink {
    function getData() public pure returns (uint256) {
        // Devolver datos predefinidos
        return 100;
    }
}

contract MyContractTest {
    function testGetDataFromChainlink() public {
        // Crear una instancia del mock de Chainlink
        MockChainlink mock = new MockChainlink();

        // Crear una instancia de MyContract pasando el mock de Chainlink
        MyContract myContract = new MyContract(mock);

        // Llamar a la función para obtener los datos de Chainlink
        uint256 data = myContract.getDataFromChainlink();

        // Verificar que los datos sean los esperados
        assert(data == 100);
    }
}
