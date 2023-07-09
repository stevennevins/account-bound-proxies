// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MultiSendCallOnly} from "src/MultiSendCallOnly.sol";
import {IFactoryCallback} from "src/interfaces/IFactoryCallback.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract Proxy {
    bytes32 internal immutable initCodeHash;
    address internal immutable deployer;
    address internal pluginLogic;
    error NotOwner();

    modifier onlyOwner() {
        address userProxy = Create2.computeAddress(
            keccak256(abi.encode(msg.sender)),
            initCodeHash,
            deployer
        );
        if (address(this) != userProxy) revert NotOwner();
        _;
    }

    constructor() {
        /// @dev workaround for circular reference
        bytes32 _initCodeHash = IFactoryCallback(msg.sender).initCodeHash();
        initCodeHash = _initCodeHash;
        deployer = msg.sender;
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

contract ProxyDeployer is IFactoryCallback {
    bytes32 public immutable initCodeHash = keccak256(type(Proxy).creationCode);
    event ProxyCreated(address indexed user, address indexed proxy);

    function createProxy(address user) external {
        address proxy = address(new Proxy{salt: keccak256(abi.encode(user))}());
        emit ProxyCreated(user, proxy);
    }
}
