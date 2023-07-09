// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProxyDeployer} from "src/Proxy.sol";

contract ProxyTest is Test {
    ProxyDeployer internal deployer;
    address owner;

    function setUp() public {
        owner = address(2);
        deployer = new ProxyDeployer();
    }

    function test_deployProxy() public {
        deployer.createProxy(owner);
    }
}
