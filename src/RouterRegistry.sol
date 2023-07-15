// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Router} from "src/Router.sol";
import {IOwner} from "src/interfaces/IOwner.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

/// @title Router Registry Contract
/// @notice This contract is used to manage the creation and retrieval of Router contracts
contract RouterRegistry {
    bytes32 public constant INIT_CODE_HASH = keccak256(type(Router).creationCode);

    event RouterCreated(address indexed user, address indexed router);

    error NotOwner();
    error RouterExists();

    /// @notice Creates a new Router contract for the specified user
    function createRouter() external {
        address user = tx.origin;
        address router = _predictRouterAddress(keccak256(abi.encode(user)));
        if (router.code.length != 0) revert RouterExists();
        emit RouterCreated(user, router);
        new Router{salt: keccak256(abi.encode(user))}();
    }

    /// @notice Checks if a Router contract exists for the specified user
    /// @param user The address of the user to check for a Router contract
    /// @return True if a Router contract exists, false otherwise
    function routerExistsFor(address user) external view returns (bool) {
        address router = _predictRouterAddress(keccak256(abi.encode(user)));
        if (router.code.length == 0) return false;
        return true;
    }

    /// @notice Gets the address of the Router contract for the specified user
    /// @param user The address of the user for whom to get the Router contract address
    /// @return The address of the Router contract
    function routerFor(address user) external view returns (address) {
        return _predictRouterAddress(keccak256(abi.encode(user)));
    }

    /// @notice Gets the owner of a Router contract
    /// @param router The address of the Router contract
    /// @return The owner address of the Router contract
    function ownerOf(address router) external view returns (address) {
        address routerOwner = IOwner(router).owner();
        if (router != _predictRouterAddress(keccak256(abi.encode(routerOwner)))) revert NotOwner();
        return routerOwner;
    }

    function _predictRouterAddress(bytes32 salt) internal view returns (address) {
        return Create2.computeAddress(salt, INIT_CODE_HASH, address(this));
    }
}
