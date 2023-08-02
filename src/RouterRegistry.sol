// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Router} from "src/Router.sol";
import {IOwner} from "src/interfaces/IOwner.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

/// @title Router Registry Contract
/// @notice This contract is used to manage the creation and retrieval of Router contracts
contract RouterRegistry {
    using Clones for address;

    bytes32 public constant INIT_CODE_HASH = keccak256(type(Router).creationCode);
    address internal routerImplementation = address(new Router());

    event RouterCreated(address indexed user, address indexed router);

    error NotOwner();
    error RouterExists();

    /// @notice Creates a new Router contract for the specified user
    function createRouter(address _user) external {
        bytes32 salt = keccak256(abi.encode(_user));
        address router = _predictRouterAddress(salt);
        if (router.code.length != 0) revert RouterExists();
        address router_ = routerImplementation.cloneDeterministic(salt);
        emit RouterCreated(_user, router);
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

    function _predictRouterAddress(bytes32 salt) internal view returns (address) {
        return Clones.predictDeterministicAddress(routerImplementation, salt);
    }
}
