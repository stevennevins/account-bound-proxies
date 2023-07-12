// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Proxy} from "src/Proxy.sol";
import {IFactoryCallback} from "src/interfaces/IFactoryCallback.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract ProxyFactory is IFactoryCallback {
    bytes32 public constant initCodeHash = keccak256(type(Proxy).creationCode);
    address public cachedUser;
    event ProxyCreated(address indexed user, address indexed proxy);
    error NotOwner();

    function ownerOf(address proxy) external view returns (address) {
        address proxyOwner = Proxy(payable(proxy)).owner();
        if (
            proxy !=
            Create2.computeAddress(
                keccak256(abi.encode(proxyOwner)),
                initCodeHash,
                address(this)
            )
        ) revert NotOwner();
        return proxyOwner;
    }

    function createProxy(address user) external {
        cachedUser = user;
        address proxy = address(new Proxy{salt: keccak256(abi.encode(user))}());
        emit ProxyCreated(user, proxy);
    }
}
