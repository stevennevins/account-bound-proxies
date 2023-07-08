// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MultiSendCallOnly} from "src/MultiSendCallOnly.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

// https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3PoolDeployer.sol
// https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol
// js lib base compatability on https://github.com/gnosis/ethers-multisend
interface ICallbackParams {
    function params() external returns (address, bytes32);
}

contract Proxy is MultiSendCallOnly {
    /// this will eventually just be a constant
    bytes32 internal immutable initCodeHash;
    address internal immutable deployer;
    address internal pluginLogic;
    error NotOwner();

    modifier onlyOwner() {
        if (
            address(this) !=
            Create2.computeAddress(
                keccak256(abi.encode(msg.sender)),
                initCodeHash,
                deployer
            )
        ) revert NotOwner();
        _;
    }

    constructor() {
        (address _owner, bytes32 _initCodeHash) = ICallbackParams(msg.sender)
            .params();

        if (
            address(this) !=
            Create2.computeAddress(
                keccak256(abi.encode(_owner)),
                _initCodeHash,
                msg.sender
            )
        ) revert NotOwner();
        initCodeHash = _initCodeHash;
        deployer = msg.sender;
    }

    // solhint-disable-next-line
    receive() external payable {}

    // solhint-disable-next-line
    fallback() external payable {
        address _impl = pluginLogic;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
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

    /// TODO see if this should be called execTransaction for better compatibility with safe libs
    function multiSend(bytes memory transactions)
        public
        payable
        override
        onlyOwner
    {
        super.multiSend(transactions);
    }
}

contract ProxyDeployer {
    bytes32 internal immutable proxyInitCodeHash;
    address internal owner;

    constructor() {
        proxyInitCodeHash = keccak256(type(Proxy).creationCode);
    }

    function createProxy(address user) external returns (address) {
        owner = user;
        address proxy = address(new Proxy{salt: keccak256(abi.encode(user))}());
        delete owner;
        return proxy;
    }

    function params() external view returns (address, bytes32) {
        return (owner, proxyInitCodeHash);
    }
}
