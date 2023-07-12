// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Router, IRegistryCallback} from "src/Router.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract RouterTest is EncodeTxs, IRegistryCallback, Test {
    Router internal router;
    bytes32 public immutable initCodeHash =
        keccak256(type(Router).creationCode);
    address public cachedUser = address(2);
    Transaction[] internal txs;

    function test_cachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        vm.prank(cachedUser);
        router.multiSend("");
    }

    function test_RevertsWhenNotcachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        vm.prank(address(3));
        vm.expectRevert();
        router.multiSend("");
    }

    function test_ExecuteTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser);
        router.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser);
        router.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        txs.push(
            Transaction(
                address(this),
                0,
                abi.encodeCall(IRegistryCallback.cachedUser, ()),
                Operation.Call
            )
        );
        vm.prank(cachedUser);
        router.multiSend(encode(txs));
    }
}
