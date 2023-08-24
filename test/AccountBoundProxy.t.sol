// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccountBoundProxy} from "src/AccountBoundProxy.sol";
import {ProxyRegistry} from "src/ProxyRegistry.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract Emitter {
    event Ping(string);

    function ping() external {
        emit Ping("Ping");
    }
}

contract AccountBoundProxyTest is EncodeTxs, Emitter, Test {
    ProxyRegistry internal deployer = new ProxyRegistry();
    address owner = address(2);
    AccountBoundProxy internal proxy;
    Transaction[] internal txs;

    function setUp() public {
        deployer.createProxy(owner);
        proxy = AccountBoundProxy(payable(deployer.proxyFor(owner)));
    }

    function test_owner() public {
        vm.prank(owner, owner);
        proxy.multiSend("");
    }

    function test_RevertsWhenNotowner() public {
        vm.prank(address(3));
        vm.expectRevert();
        proxy.multiSend("");
    }

    function test_ExecuteTransfer() public {
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner, owner);
        proxy.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner, owner);
        proxy.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        txs.push(Transaction(address(this), 0, abi.encodeCall(Emitter.ping, ()), Operation.Call));
        vm.prank(owner, owner);
        proxy.multiSend(encode(txs));
    }
}
