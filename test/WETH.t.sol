// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccountBoundProxy} from "src/AccountBoundProxy.sol";
import {ProxyRegistry} from "src/ProxyRegistry.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";
import {WETH9} from "test/examples/WETH9.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {MockPullWETH} from "test/examples/mocks/MockPullWETH.sol";

contract WETHTest is EncodeTxs, Test {
    ProxyRegistry internal registry = new ProxyRegistry();
    WETH9 internal weth9 = new WETH9();
    address internal owner = address(2);
    Transaction[] internal txs;
    AccountBoundProxy internal proxy;
    MockPullWETH internal puller;

    function setUp() public {
        vm.prank(owner, owner);
        registry.createProxy(owner);
        proxy = AccountBoundProxy(payable(registry.proxyFor(owner)));
    }

    function test_EOA_WETH9() public {
        puller = new MockPullWETH(address(weth9));
        vm.deal(owner, 1 ether);
        vm.startPrank(owner, owner);
        weth9.deposit{value: 1 ether}();
        weth9.approve(address(puller), type(uint256).max);
        puller.depositWETH(1 ether);
        vm.stopPrank();
    }

    function test_Multisend_WETH9() public {
        puller = new MockPullWETH(address(weth9));
        txs.push(
            Transaction(address(weth9), 1 ether, abi.encodeCall(WETH9.deposit, ()), Operation.Call)
        );
        txs.push(
            Transaction(
                address(weth9),
                0,
                abi.encodeCall(WETH9.approve, (address(puller), type(uint256).max)),
                Operation.Call
            )
        );
        txs.push(
            Transaction(
                address(puller),
                0,
                abi.encodeCall(MockPullWETH.depositWETH, (1 ether)),
                Operation.Call
            )
        );

        vm.deal(owner, 1 ether);
        vm.prank(owner);
        proxy.multiSend{value: 1 ether}(encode(txs));
    }
}
