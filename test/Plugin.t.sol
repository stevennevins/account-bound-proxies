// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Router} from "src/Router.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";
import {NFTReceiver} from "test/examples/plugins/NFTReceiver.sol";
import {MockERC721} from "test/examples/mocks/MockERC721.sol";
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

contract NFTReceiverTest is PluginTest {
    MockERC721 internal nft;
    uint256 internal id;

    function setUp() public override {
        plugin = address(new NFTReceiver());
        super.setUp();
        nft = new MockERC721();
        id = 1;
    }

    function test_ReceiverNFTs() public {
        nft.mint(address(this), id);
        nft.safeTransferFrom(address(this), address(router), id);
    }

    function test_RevertsWhenNotInstalled() public {
        vm.prank(owner, owner);
        router.updatePluginLogic(address(0));
        nft.mint(address(this), id);
        vm.expectRevert();
        nft.safeTransferFrom(address(this), address(router), id);
    }
}
