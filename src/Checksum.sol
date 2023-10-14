/*pragma solidity ^0.8.0;

contract AddressChecksum {
    function calculateChecksum(address _address) public pure returns (bytes32) {
        bytes memory addressBytes = abi.encodePacked(_address);
        bytes32 hash = keccak256(addressBytes);
        bytes32 checksum = 0x0;

        for (uint i = 0; i < addressBytes.length; i++) {
            if ((addressBytes[i] >= 0x41 && addressBytes[i] <= 0x5A) || (addressBytes[i] % 32 == 0)) {
                checksum |= bytes32(uint256(addressBytes[i]) << (31 * 8 - i * 8));
            }
        }

        return checksum;
    }
}*/