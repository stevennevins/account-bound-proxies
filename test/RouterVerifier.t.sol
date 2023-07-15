// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RouterVerify} from "test/examples/lib/RouterVerify.sol";
import {RouterRegistry} from "src/RouterRegistry.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract RouterVerifyTest is Test {
    RouterRegistry internal registry;
    address owner = address(2);

    function setUp() public {
        registry = new RouterRegistry();
        registry.createRouter(owner);
    }

    function test_Verify() public {
        assertTrue(RouterVerify.proveOwnerOf(getRouterAddress(owner), owner, address(registry)));
    }

    function getRouterAddress(address _user) internal view returns (address) {
        address userRouter = Create2.computeAddress(
            keccak256(abi.encode(_user)), registry.INIT_CODE_HASH(), address(registry)
        );
        require(userRouter.code.length > 0, "no code");
        return userRouter;
    }
}
