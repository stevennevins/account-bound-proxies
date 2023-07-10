// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IFactoryCallback {
    function cachedUser() external returns (address);
}
