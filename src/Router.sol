// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MultiSendCallOnly} from "src/lib/MultiSendCallOnly.sol";
import {IRegistryCallback} from "src/interfaces/IRegistryCallback.sol";
import {Proxy} from "openzeppelin-contracts/contracts/proxy/Proxy.sol";

contract Router is Proxy {
    address internal immutable owner;
    address internal pluginLogic;

    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() payable {
        owner = IRegistryCallback(msg.sender).cachedUser();
    }

    function updatePluginLogic(address _pluginLogic) external onlyOwner {
        pluginLogic = _pluginLogic;
    }

    function multiSend(bytes memory transactions) external payable onlyOwner {
        MultiSendCallOnly.multiSend(transactions);
    }

    function _beforeFallback() internal view override {
        if (msg.sig == bytes4(keccak256("owner()"))) {
            address owner_ = owner;
            assembly {
                let result := owner_
                mstore(0x0, result) // store result in memory
                return(0x0, 20)
            }
        }
    }

    function _implementation() internal view override returns (address) {
        return pluginLogic;
    }
}
