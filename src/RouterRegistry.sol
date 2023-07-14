// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Router} from "src/Router.sol";
import {IRegistryCallback} from "src/interfaces/IRegistryCallback.sol";
import {IOwner} from "src/interfaces/IOwner.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract RouterRegistry is IRegistryCallback {
    bytes32 public constant INIT_CODE_HASH =
        keccak256(type(Router).creationCode);
    address public cachedUser;
    event RouterCreated(address indexed user, address indexed router);
    error NotOwner();
    error RouterExists();

    function createRouter(address user) external {
        address router = _predictRouterAddress(keccak256(abi.encode(user)));
        if (router.code.length != 0) revert RouterExists();
        cachedUser = user;
        emit RouterCreated(user, router);
        new Router{salt: keccak256(abi.encode(user))}();
    }

    function routerExistsFor(address user) external view returns (bool) {
        address router = _predictRouterAddress(keccak256(abi.encode(user)));
        if (router.code.length == 0) return false;
        return true;
    }

    function routerFor(address user) external view returns (address) {
        return _predictRouterAddress(keccak256(abi.encode(user)));
    }

    function ownerOf(address router) external view returns (address) {
        address routerOwner = IOwner(router).owner();
        if (router != _predictRouterAddress(keccak256(abi.encode(routerOwner))))
            revert NotOwner();
        return routerOwner;
    }

    function _predictRouterAddress(bytes32 salt)
        internal
        view
        returns (address)
    {
        return Create2.computeAddress(salt, INIT_CODE_HASH, address(this));
    }
}
