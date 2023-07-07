// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {MultiSendCallOnly} from "src/MultiSendCallOnly.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

// https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3PoolDeployer.sol
// https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/PoolAddress.sol
interface ICallbackParams {
    function params() external returns (address, bytes32);
}

contract Proxy is MultiSendCallOnly {
    /// this will eventually just be a constant
    bytes32 internal immutable initCodeHash;
    address internal immutable deployer;

    constructor() {
        (address _owner, bytes32 _initCodeHash) = ICallbackParams(msg.sender)
            .params();
        require(
            address(this) ==
                Create2.computeAddress(
                    keccak256(abi.encode(_owner)),
                    _initCodeHash,
                    msg.sender
                ),
            "invalid"
        );
        initCodeHash = _initCodeHash;
        deployer = msg.sender;
    }

    modifier onlyOwner() {
        require(
            address(this) ==
                Create2.computeAddress(
                    keccak256(abi.encode(msg.sender)),
                    initCodeHash,
                    deployer
                ),
            "not owner"
        );
        _;
    }

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
    bytes32 public immutable proxyInitCodeHash;
    address owner;

    constructor() {
        proxyInitCodeHash = keccak256(type(Proxy).creationCode);
    }

    function createProxy(address user) external returns (address) {
        owner = user;
        address proxy = address(new Proxy{salt: keccak256(abi.encode(user))}());
        delete owner;
        return proxy;
    }

    function params() external returns (address, bytes32) {
        return (owner, proxyInitCodeHash);
    }
}
