// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
pragma solidity ^0.8.13;

import {IWETH9} from "test/examples/interfaces/IWETH9.sol";
import {IForkedWETH} from "test/examples/interfaces/IForkedWETH.sol";

contract WethConverter {
    address internal weth9;
    address internal forkedWETH;

    receive() external payable {}

    constructor(address _weth9, address _forkedWETH) {
        weth9 = _weth9;
        forkedWETH = _forkedWETH;
    }

    function weth9ToForkedWETH(address account, uint256 value) external payable {
        IWETH9(weth9).transferFrom(account, address(this), value);
        IWETH9(weth9).withdraw(value);
        IForkedWETH(forkedWETH).depositTo{value: value + msg.value}(account);
    }

    function forkedWETHToWeth9(address account, uint256 value) external payable {
        IForkedWETH(forkedWETH).withdrawFrom(account, value, address(this));
        uint256 combined = value + msg.value;
        IWETH9(weth9).deposit{value: combined}();
        IWETH9(weth9).transfer(account, combined);
    }
}
