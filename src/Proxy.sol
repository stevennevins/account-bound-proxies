// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MultiSendCallOnly} from "src/lib/MultiSendCallOnly.sol";
import {IFactoryCallback} from "src/interfaces/IFactoryCallback.sol";

contract Proxy {
    address internal immutable owner;
    address internal pluginLogic;
    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = IFactoryCallback(msg.sender).cachedUser();
    }

    // solhint-disable-next-line
    receive() external payable {}

    // solhint-disable-next-line
    fallback() external payable {
        address logic = pluginLogic;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), logic, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    function updatePluginLogic(address _pluginLogic) external onlyOwner {
        pluginLogic = _pluginLogic;
    }

    function multiSend(bytes memory transactions) external payable onlyOwner {
        MultiSendCallOnly.multiSend(transactions);
    }
}
