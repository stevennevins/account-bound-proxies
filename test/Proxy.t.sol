// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Proxy, ICallbackParams} from "src/Proxy.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract ProxyTest is EncodeTxs, ICallbackParams, Test {
    Proxy internal proxy;
    bytes32 internal immutable initCodeHash;
    address internal owner;
    Transaction[] internal txs;

    function params() external view returns (address, bytes32) {
        return (owner, initCodeHash);
    }

    constructor() {
        initCodeHash = keccak256(type(Proxy).creationCode);
    }

    function setUp() public {
        owner = address(2);
    }

    function test_Owner() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.prank(owner);
        proxy.multiSend("");
    }

    function test_RevertsWhenNotOwner() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.prank(address(3));
        vm.expectRevert();
        proxy.multiSend("");
    }

    function test_ExecuteTransfer() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner);
        proxy.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner);
        proxy.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        txs.push(
            Transaction(
                address(this),
                0,
                abi.encodeCall(ICallbackParams.params, ()),
                Operation.Call
            )
        );
        vm.prank(owner);
        proxy.multiSend(encode(txs));
    }
}
