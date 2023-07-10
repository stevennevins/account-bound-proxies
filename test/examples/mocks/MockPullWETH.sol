// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract MockPullWETH {
    address internal weth;

    constructor(address _wethLike) {
        weth = _wethLike;
    }

    function depositWETH(uint256 amount) external {
        IERC20(weth).transferFrom(msg.sender, address(this), amount);
    }
}
