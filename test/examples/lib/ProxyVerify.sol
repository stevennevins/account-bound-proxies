// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {ProxyMultiSender} from "src/ProxyMultiSender.sol";

library ProxyVerify {
    bytes32 public constant initCodeHash =
        keccak256(type(ProxyMultiSender).creationCode);

    function proveOwnerOf(
        address proxy,
        address owner,
        address deployer
    ) internal pure returns (bool) {
        return
            proxy ==
            Create2.computeAddress(
                keccak256(abi.encode(owner)),
                initCodeHash,
                deployer
            );
    }
}
