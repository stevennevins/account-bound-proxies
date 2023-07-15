// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Router} from "src/Router.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

interface Cached {
    function cachedUser() external;
}

contract RouterTest is EncodeTxs, Test {
    Router internal router;
    bytes32 public immutable initCodeHash = keccak256(type(Router).creationCode);
    address public cachedUser = address(2);
    Transaction[] internal txs;

    function test_cachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        vm.prank(cachedUser, cachedUser);
        router = new Router{salt: salt}();
        vm.prank(cachedUser, cachedUser);
        router.multiSend("");
    }

    function test_RevertsWhenNotcachedUser() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        vm.prank(cachedUser, cachedUser);
        router = new Router{salt: salt}();
        vm.prank(address(3));
        vm.expectRevert();
        router.multiSend("");
    }

    function test_ExecuteTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        vm.prank(cachedUser, cachedUser);
        router = new Router{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser, cachedUser);
        router.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        vm.prank(cachedUser, cachedUser);
        router = new Router{salt: salt}();
        vm.deal(cachedUser, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(cachedUser, cachedUser);
        router.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        vm.prank(cachedUser, cachedUser);
        router = new Router{salt: salt}();
        txs.push(
            Transaction(address(this), 0, abi.encodeCall(Cached.cachedUser, ()), Operation.Call)
        );
        vm.prank(cachedUser, cachedUser);
        router.multiSend(encode(txs));
    }
}
