// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRegistryCallback {
    function cachedUser() external returns (address);
}
