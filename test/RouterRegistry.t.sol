// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";

contract RouterRegistryTest is Test {
    RouterRegistry internal deployer = new RouterRegistry();
    address owner = address(2);

    function test_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createRouter(owner);
    }

    function test_RevertsWhenSameOwner_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createRouter(owner);
        vm.prank(owner, owner);
        vm.expectRevert();
        deployer.createRouter(owner);
    }
}
