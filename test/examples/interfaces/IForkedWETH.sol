// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2015, 2016, 2017 Dapphub
pragma solidity ^0.8.13;

interface IForkedWETH {
    function depositTo(address) external payable;

    function withdrawFrom(
        address,
        uint256,
        address
    ) external;
}
