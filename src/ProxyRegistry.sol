// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccountBoundProxy} from "src/AccountBoundProxy.sol";
import {IOwner} from "src/interfaces/IOwner.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

/// @title AccountBoundProxy Registry Contract
/// @notice This contract is used to manage the creation and retrieval of AccountBoundProxy
/// contracts
contract ProxyRegistry {
    using Clones for address;

    bytes32 public constant INIT_CODE_HASH = keccak256(type(AccountBoundProxy).creationCode);
    address internal immutable PROXY_IMPLEMENTATION = address(new AccountBoundProxy());

    event ProxyCreated(address indexed user, address indexed proxy);

    error NotOwner();
    error ProxyExists();

    /// @notice Creates a new AccountBoundProxy contract for the specified user
    function createProxy(address _user) external {
        bytes32 salt = keccak256(abi.encode(_user));
        address proxy = _predictProxyAddressFor(salt);
        if (proxy.code.length != 0) revert ProxyExists();
        address proxy_ = PROXY_IMPLEMENTATION.cloneDeterministic(salt);
        emit ProxyCreated(_user, proxy);
    }

    /// @notice Checks if a AccountBoundProxy contract exists for the specified user
    /// @param user The address of the user to check for a AccountBoundProxy contract
    /// @return True if a AccountBoundProxy contract exists, false otherwise
    function proxyExistsFor(address user) external view returns (bool) {
        address proxy = _predictProxyAddressFor(keccak256(abi.encode(user)));
        if (proxy.code.length == 0) return false;
        return true;
    }

    /// @notice Gets the address of the AccountBoundProxy contract for the specified user
    /// @param user The address of the user for whom to get the AccountBoundProxy contract address
    /// @return The address of the AccountBoundProxy contract
    function proxyFor(address user) external view returns (address) {
        return _predictProxyAddressFor(keccak256(abi.encode(user)));
    }

    function _predictProxyAddressFor(bytes32 salt) internal view returns (address) {
        return Clones.predictDeterministicAddress(PROXY_IMPLEMENTATION, salt);
    }
}
