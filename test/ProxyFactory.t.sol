// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProxyFactory} from "src/Proxy.sol";

contract ProxyFactoryTest is Test {
    ProxyFactory internal deployer = new ProxyFactory();
    address owner = address(2);

    function test_deployProxy() public {
        deployer.createProxy(owner);
    }
}
