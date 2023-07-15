// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";

contract RouterRegistryTest is Test {
    RouterRegistry internal deployer = new RouterRegistry();
    address owner = address(2);

    function test_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createRouter();
    }

    function test_RevertsWhenSameOwner_deployProxy() public {
        vm.prank(owner, owner);
        deployer.createRouter();
        vm.prank(owner, owner);
        vm.expectRevert();
        deployer.createRouter();
    }

    function test_deployMultiGasCheck() public {
        vm.prank(owner, owner);
        deployer.createRouter();
        vm.prank(owner, address(100));
        deployer.createRouter();
        vm.prank(owner, address(101));
        deployer.createRouter();
        vm.prank(owner, address(102));
        deployer.createRouter();
        vm.prank(owner, address(103));
        deployer.createRouter();
        vm.prank(owner, address(104));
        deployer.createRouter();
        vm.prank(owner, address(105));
        deployer.createRouter();
        vm.prank(owner, address(106));
        deployer.createRouter();
        vm.prank(owner, address(107));
        deployer.createRouter();
        vm.prank(owner, address(108));
        deployer.createRouter();
        vm.prank(owner, address(109));
        deployer.createRouter();
        vm.prank(owner, address(110));
        deployer.createRouter();
    }
}
