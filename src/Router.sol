// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MultiSendCallOnly} from "src/lib/MultiSendCallOnly.sol";
import {ERC1155Holder} from "openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Proxy} from "openzeppelin-contracts/contracts/proxy/Proxy.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

/// @title Router Contract
/// @notice A contract that acts as a router and proxy for executing multiple transactions.
contract Router is Proxy, ERC1155Holder, ERC721Holder {
    /// @notice The router registry
    address internal immutable registry = msg.sender;
    /// @notice The router implementation
    address internal immutable routerImplementation = address(this);
    /// @notice Option logic that can be installed to enhance functionality of the router
    address internal pluginLogic;

    /// @notice Error when caller is not owner of the router
    error NotOwner();

    /// @notice Updates the plugin logic address.
    /// @param _pluginLogic The new plugin logic address.

    function updatePluginLogic(address _pluginLogic) external {
        _checkOwner();
        pluginLogic = _pluginLogic;
    }

    /// @notice Executes multiple transactions in a single call.
    /// @param transactions The byte array containing the encoded transactions.
    function multiSend(bytes memory transactions) external payable {
        _checkOwner();
        MultiSendCallOnly.multiSend(transactions);
    }

    function _implementation() internal view override returns (address) {
        return pluginLogic;
    }

    function _checkOwner() internal view {
        address router = Clones.predictDeterministicAddress(
            routerImplementation, keccak256(abi.encode(msg.sender)), registry
        );
        if (router != address(this)) revert NotOwner();
    }
}
