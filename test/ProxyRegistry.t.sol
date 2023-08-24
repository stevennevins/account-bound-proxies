// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProxyRegistry} from "src/ProxyRegistry.sol";

contract ProxyRegistryTest is Test {
    ProxyRegistry internal deployer = new ProxyRegistry();
    address owner = address(2);

    function test_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createProxy(owner);
    }

    function test_RevertsWhenSameOwner_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createProxy(owner);
        vm.prank(owner, owner);
        vm.expectRevert();
        deployer.createProxy(owner);
    }
}
