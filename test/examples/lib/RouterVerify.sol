// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {Router} from "src/Router.sol";

library RouterVerify {
    bytes32 public constant initCodeHash = keccak256(type(Router).creationCode);

    function proveOwnerOf(address router, address owner, address deployer)
        internal
        pure
        returns (bool)
    {
        return
            router == Create2.computeAddress(keccak256(abi.encode(owner)), initCodeHash, deployer);
    }
}
