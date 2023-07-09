// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Proxy, IFactoryCallback} from "src/Proxy.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";
import {ForkedWETH9} from "test/examples/ForkedWETH.sol";

contract ForkedWETHTest is EncodeTxs, IFactoryCallback, Test {
    Proxy internal proxy;
    ForkedWETH9 internal weth;
    bytes32 internal _initCodeHash;
    address internal owner;
    Transaction[] internal txs;

    function initCodeHash() external view returns (bytes32) {
        return _initCodeHash;
    }

    constructor() {
        _initCodeHash = keccak256(type(Proxy).creationCode);
    }

    function setUp() public {
        owner = address(2);
        weth = new ForkedWETH9(address(this));
    }

    function test_ExecuteMultisendWithWETh() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner);
        proxy.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteTransferWithWETH() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner);
        proxy.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }
}
