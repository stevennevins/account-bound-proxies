// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Router} from "src/Router.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract PluginTest is EncodeTxs, Test {
    RouterRegistry internal registry = new RouterRegistry();
    Router internal router;
    address internal plugin;
    address public owner = address(2);
    Transaction[] internal txs;

    function setUp() public virtual {
        registry.createRouter(owner);
        router = Router(payable(registry.routerFor(owner)));
        vm.prank(owner, owner);
        router.updatePluginLogic(plugin);
    }
}
