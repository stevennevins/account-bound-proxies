// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProxyFactory} from "src/Proxy.sol";

contract ProxyTest is Test {
    ProxyFactory internal deployer;
    address owner;

    function setUp() public {
        owner = address(2);
        deployer = new ProxyFactory();
    }

    function test_deployProxy() public {
        deployer.createProxy(owner);
    }
}
