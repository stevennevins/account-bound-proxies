// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ProxyMultiSender} from "src/ProxyMultiSender.sol";
import {IFactoryCallback} from "src/interfaces/IFactoryCallback.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract ProxyFactory is IFactoryCallback {
    bytes32 public constant INIT_CODE_HASH =
        keccak256(type(ProxyMultiSender).creationCode);
    address public cachedUser;
    event ProxyCreated(address indexed user, address indexed proxy);
    error NotOwner();

    function createProxy(address user) external {
        cachedUser = user;
        address proxy = address(
            new ProxyMultiSender{salt: keccak256(abi.encode(user))}()
        );
        emit ProxyCreated(user, proxy);
    }

    function ownerOf(address proxy) external view returns (address) {
        address proxyOwner = ProxyMultiSender(payable(proxy)).owner();
        if (
            proxy !=
            Create2.computeAddress(
                keccak256(abi.encode(proxyOwner)),
                INIT_CODE_HASH,
                address(this)
            )
        ) revert NotOwner();
        return proxyOwner;
    }
}
