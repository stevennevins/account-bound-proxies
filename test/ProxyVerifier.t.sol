// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProxyVerify} from "test/examples/lib/ProxyVerify.sol";
import {ProxyFactory} from "src/ProxyFactory.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract ProxyVerifierTest is Test {
    ProxyFactory internal factory;
    address owner = address(2);

    function setUp() public {
        factory = new ProxyFactory();
        factory.createProxy(owner);
    }

    function test_Verify() public {
        assertTrue(
            ProxyVerify.proveOwnerOf(
                getProxyAddress(owner),
                owner,
                address(factory)
            )
        );
    }

    function getProxyAddress(address _user) internal view returns (address) {
        address userProxy = Create2.computeAddress(
            keccak256(abi.encode(_user)),
            factory.INIT_CODE_HASH(),
            address(factory)
        );
        require(userProxy.code.length > 0, "no code");
        return userProxy;
    }
}
