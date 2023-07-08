// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
pragma solidity ^0.8.13;

interface IWETH9 {
    function withdraw(uint256) external;

    function deposit() external payable;

    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}
