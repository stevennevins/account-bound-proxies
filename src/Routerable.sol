// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {Router} from "src/Router.sol";

abstract contract Routerable {
    address internal routerRegistry;
    bytes32 public constant INIT_CODE_HASH = keccak256(type(Router).creationCode);

    modifier authorizedUserOrRouter() {
        address authorized = _authorizedUser();
        require(
            msg.sender == authorized
                || msg.sender == _predictRouterAddress(keccak256(abi.encode(authorized))),
            "Caller is not the user or the user's router"
        );
        _;
    }

    constructor(address _routerRegistry) {
        routerRegistry = _routerRegistry;
    }

    function _authorizedUser() internal view virtual returns (address);

    function _predictRouterAddress(bytes32 salt) internal view returns (address) {
        return Create2.computeAddress(salt, INIT_CODE_HASH, routerRegistry);
    }
}
