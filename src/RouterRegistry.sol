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

    function createRouter(address user) external {
        cachedUser = user;
        emit RouterCreated(
            user,
            address(new Router{salt: keccak256(abi.encode(user))}())
        );
    }

    function ownerOf(address router) external view returns (address) {
        address routerOwner = IOwner(router).owner();
        if (
            router !=
            Create2.computeAddress(
                keccak256(abi.encode(routerOwner)),
                INIT_CODE_HASH,
                address(this)
            )
        ) revert NotOwner();
        return routerOwner;
    }
}
