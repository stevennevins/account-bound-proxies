// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Router, IRegistryCallback} from "src/Router.sol";
import {NFTReceiver} from "test/examples/plugins/NFTReceiver.sol";
import {MockERC721} from "test/examples/mocks/MockERC721.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";

contract PluginTest is EncodeTxs, IRegistryCallback, Test {
    Router internal router;
    address internal plugin;
    bytes32 public immutable initCodeHash = keccak256(type(Router).creationCode);
    address public cachedUser = address(2);
    Transaction[] internal txs;

    function setUp() public virtual {
        bytes32 salt = keccak256(abi.encode(cachedUser));
        router = new Router{salt: salt}();
        vm.prank(cachedUser);
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
        vm.prank(cachedUser);
        router.updatePluginLogic(address(0));
        nft.mint(address(this), id);
        vm.expectRevert();
        nft.safeTransferFrom(address(this), address(router), id);
    }
}
