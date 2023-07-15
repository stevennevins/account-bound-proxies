// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IRegistryCallback {
    function cachedUser() external returns (address);
}
