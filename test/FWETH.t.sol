// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Proxy, IFactoryCallback} from "src/Proxy.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";
import {FWETH} from "test/examples/FWETH.sol";

contract FWETHTest is EncodeTxs, IFactoryCallback, Test {
    Proxy internal proxy;
    FWETH internal weth;
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
        weth = new FWETH(address(this));
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
