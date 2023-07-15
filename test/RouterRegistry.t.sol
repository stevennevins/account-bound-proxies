// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    function test_deployMultiGasCheck() public {
        deployer.createRouter(owner);
        deployer.createRouter(address(100));
        deployer.createRouter(address(101));
        deployer.createRouter(address(102));
        deployer.createRouter(address(103));
        deployer.createRouter(address(104));
        deployer.createRouter(address(105));
        deployer.createRouter(address(106));
        deployer.createRouter(address(107));
        deployer.createRouter(address(108));
        deployer.createRouter(address(109));
        deployer.createRouter(address(110));
    }
}
