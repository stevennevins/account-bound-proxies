// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccountBoundProxy} from "src/AccountBoundProxy.sol";
import {ProxyRegistry} from "src/ProxyRegistry.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract PluginTest is EncodeTxs, Test {
    ProxyRegistry internal registry = new ProxyRegistry();
    AccountBoundProxy internal proxy;
    address internal plugin;
    address public owner = address(2);
    Transaction[] internal txs;

    function setUp() public virtual {
        registry.createProxy(owner);
        proxy = AccountBoundProxy(payable(registry.proxyFor(owner)));
        vm.prank(owner, owner);
        proxy.updatePluginLogic(plugin);
    }
}
