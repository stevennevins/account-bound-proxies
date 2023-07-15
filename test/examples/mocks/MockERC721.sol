// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721("", "") {
    function mint(address to, uint256 tokenId) external {
        super._mint(to, tokenId);
    }
}
