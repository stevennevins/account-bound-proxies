// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";

contract RouterRegistryTest is Test {
    RouterRegistry internal deployer = new RouterRegistry();
    address owner = address(2);

    function test_deployProxy() public {
        deployer.createRouter(owner);
    }

    function test_RevertsWhenSameOwner_deployProxy() public {
        deployer.createRouter(owner);
        vm.expectRevert();
        deployer.createRouter(owner);
    }
}
