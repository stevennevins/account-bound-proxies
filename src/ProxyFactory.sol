// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Proxy} from "src/Proxy.sol";
import {IFactoryCallback} from "src/interfaces/IFactoryCallback.sol";

contract ProxyFactory is IFactoryCallback {
    bytes32 public immutable initCodeHash = keccak256(type(Proxy).creationCode);
    address public cachedUser;
    event ProxyCreated(address indexed user, address indexed proxy);

    function createProxy(address user) external {
        cachedUser = user;
        address proxy = address(new Proxy{salt: keccak256(abi.encode(user))}());
        emit ProxyCreated(user, proxy);
    }
}
