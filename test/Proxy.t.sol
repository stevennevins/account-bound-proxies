// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "forge-std/Test.sol";
import "src/Proxy.sol";

contract ProxyTest is Test {
    Proxy public proxy;
    bytes32 public initCodeHash;
    address owner;

    function params() public returns (address, bytes32) {
        return (owner, initCodeHash);
    }

    function setUp() public {
        initCodeHash = keccak256(type(Proxy).creationCode);
        owner = address(2);
    }

    function test_Owner() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.prank(owner);
        proxy.call();
    }

    function test_RevertsWhenNotOwner() public {
        bytes32 salt = keccak256(abi.encode(owner));
        proxy = new Proxy{salt: salt}();
        vm.prank(address(3));
        vm.expectRevert();
        proxy.call();
    }
}
