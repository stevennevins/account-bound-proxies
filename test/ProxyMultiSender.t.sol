// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProxyMultiSender, IFactoryCallback} from "src/ProxyMultiSender.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract ProxyMultiSenderTest is EncodeTxs, IFactoryCallback, Test {
    ProxyMultiSender internal proxy;
    bytes32 public immutable initCodeHash =
        keccak256(type(ProxyMultiSender).creationCode);
    address public cachedUser = address(2);
    Transaction[] internal txs;

    function test_cachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        proxy = new ProxyMultiSender{salt: salt}();
        vm.prank(cachedUser);
        proxy.multiSend("");
    }

    function test_RevertsWhenNotcachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        proxy = new ProxyMultiSender{salt: salt}();
        vm.prank(address(3));
        vm.expectRevert();
        proxy.multiSend("");
    }

    function test_ExecuteTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        proxy = new ProxyMultiSender{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser);
        proxy.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        proxy = new ProxyMultiSender{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser);
        proxy.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        proxy = new ProxyMultiSender{salt: salt}();
        txs.push(
            Transaction(
                address(this),
                0,
                abi.encodeCall(IFactoryCallback.cachedUser, ()),
                Operation.Call
            )
        );
        vm.prank(cachedUser);
        proxy.multiSend(encode(txs));
    }
}
