// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MultiSendCallOnly} from "src/lib/MultiSendCallOnly.sol";
import {IRegistryCallback} from "src/interfaces/IRegistryCallback.sol";

contract Router {
    address internal immutable owner;
    address internal pluginLogic;
    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = IRegistryCallback(msg.sender).cachedUser();
    }

    // solhint-disable-next-line
    receive() external payable {}

    // solhint-disable-next-line
    fallback() external payable {
        if (msg.sig == bytes4(keccak256("owner()"))) {
            address owner_ = owner;
            assembly {
                let result := owner_
                mstore(0x0, result) // store result in memory
                return(0x0, 20)
            }
        }
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
