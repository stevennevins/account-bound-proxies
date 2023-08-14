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
    using Clones for address;
    /// @notice The router registry

    address internal immutable registry = msg.sender;
    /// @notice The router implementation
    address internal immutable routerImplementation = address(this);
    /// @notice Option logic that can be installed to enhance functionality of the router
    address internal pluginLogic;
contract Router is Proxy, ERC1155Holder, ERC721Holder {
    contract Router is Proxy, ERC1155Holder, ERC721Holder {
        using Clones for address;
        address internal immutable registry = msg.sender;
        address internal immutable routerImplementation = address(this);
        address internal pluginLogic;
        uint256 public nonce;
    
        error NotOwner();
    
        function updatePluginLogic(address _pluginLogic) external {
            _checkOwner();
            pluginLogic = _pluginLogic;
        }
    
        function multiSend(bytes calldata transactions) external payable {
            _checkOwner();
            MultiSendCallOnly.multiSend(transactions);
        }
    
        function signedMultiSend(bytes calldata transactions, bytes calldata signature, uint256 _nonce) external {
            _checkOwner();
            // Verify the signature and recover the owner address
            address recoveredOwner = recoverOwner(transactions, signature);
            // Check if the recovered owner address matches the current owner of the router
            require(recoveredOwner == msg.sender, "Invalid signature");
            // Increment the nonce value randomly
            nonce = _nonce + 1;
            // Call the multiSend function with the provided transactions parameter
            multiSend(transactions);
        }
    
        function _implementation() internal view override returns (address) {
            return pluginLogic;
        }
    
        function _checkOwner() internal view {
            address router = routerImplementation.predictDeterministicAddress(
                keccak256(abi.encode(msg.sender)), registry
            );
            if (router != address(this)) revert NotOwner();
        }
    }

    function _implementation() internal view override returns (address) {
        return pluginLogic;
    }

    function _checkOwner() internal view {
        address router = routerImplementation.predictDeterministicAddress(
            keccak256(abi.encode(msg.sender)), registry
        );
        if (router != address(this)) revert NotOwner();
    }

    function recoverOwner(bytes calldata transactions, bytes calldata signature) internal pure returns (address) {
        // Implement signature recovery logic here
        // ...
    }
}
