// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Router} from "src/Router.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract Emitter {
    event Ping(string);

    function ping() external {
        emit Ping("Ping");
    }
}

contract RouterTest is EncodeTxs, Emitter, Test {
    RouterRegistry internal deployer = new RouterRegistry();
    address owner = address(2);
    Router internal router;
    Transaction[] internal txs;

    function setUp() public {
        deployer.createRouter(owner);
        router = Router(payable(deployer.routerFor(owner)));
    }

    function test_owner() public {
        vm.prank(owner, owner);
        router.multiSend("");
    }

    function test_RevertsWhenNotowner() public {
        vm.prank(address(3));
        vm.expectRevert();
        router.multiSend("");
    }

    function test_ExecuteTransfer() public {
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner, owner);
        router.multiSend{value: 1}(encode(txs));
        assertEq(address(4).balance, 1);
    }

    function test_ExecuteMultipleTransfer() public {
        vm.deal(owner, 1 ether);
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        txs.push(Transaction(address(4), 1, hex"", Operation.Call));
        vm.prank(owner, owner);
        router.multiSend{value: 2}(encode(txs));
        assertEq(address(4).balance, 2);
    }

    function test_EncodedCall() public {
        txs.push(Transaction(address(this), 0, abi.encodeCall(Emitter.ping, ()), Operation.Call));
        vm.prank(owner, owner);
        router.multiSend(encode(txs));
    }

    function test_SignedMultiSend() public {
        bytes memory transactions = encode(txs);
        bytes memory signature = "0x1234567890abcdef";
        uint256 nonce = 1;
        router.signedMultiSend(transactions, signature, nonce);
        // Add assertions to test the functionality of verifying the signature, recovering the owner address, and incrementing the nonce
        // ...
        // Add assertions here to test the functionality of verifying the signature, recovering the owner address, and incrementing the nonce
    }
}
