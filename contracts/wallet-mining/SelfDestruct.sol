// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SelfDestruct {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function selfDestruct() external {
        selfdestruct(payable(msg.sender));
    }

    function proxiableUUID() external view returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
}
