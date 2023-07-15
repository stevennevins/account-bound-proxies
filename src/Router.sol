// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MultiSendCallOnly} from "src/lib/MultiSendCallOnly.sol";
import {IRegistryCallback} from "src/interfaces/IRegistryCallback.sol";
import {Proxy} from "openzeppelin-contracts/contracts/proxy/Proxy.sol";

/// @title Router Contract
/// @notice A contract that acts as a router and proxy for executing multiple transactions.
contract Router is Proxy {
    /// @notice The owner of the Router
    address internal immutable owner;
    /// @notice Option logic that can be installed to enhance functionality of the router
    address internal pluginLogic;

    /// @notice Error when caller is not owner of the router
    error NotOwner();

    /// @dev Modifier to ensure that only the owner can execute a function.
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() payable {
        owner = IRegistryCallback(msg.sender).cachedUser();
    }

    /// @notice Updates the plugin logic address.
    /// @param _pluginLogic The new plugin logic address.
    function updatePluginLogic(address _pluginLogic) external onlyOwner {
        pluginLogic = _pluginLogic;
    }

    /// @notice Executes multiple transactions in a single call.
    /// @param transactions The byte array containing the encoded transactions.
    function multiSend(bytes memory transactions) external payable onlyOwner {
        MultiSendCallOnly.multiSend(transactions);
    }

    function _beforeFallback() internal view override {
        if (msg.sig == bytes4(keccak256("owner()"))) {
            address owner_ = owner;
            assembly {
                let result := owner_
                mstore(0x0, result)
                return(0x0, 20)
            }
        }
    }

    function _implementation() internal view override returns (address) {
        return pluginLogic;
    }
}
