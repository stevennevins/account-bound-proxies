// Copyright (C) 2015, 2016, 2017 Dapphub

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.8.13;

import {ProxyVerify} from "test/examples/lib/ProxyVerify.sol";

/// @notice Forked WETH9 with support for account bound proxies
contract ForkedWETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;
    address public userProxyDeployer;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    fallback() external payable {
        depositTo(msg.sender);
    }

    receive() external payable {
        depositTo(msg.sender);
    }

    constructor(address _userProxyDeployer) {
        userProxyDeployer = _userProxyDeployer;
    }

    function depositTo(address to) public payable {
        balanceOf[to] += msg.value;
        emit Deposit(to, msg.value);
    }

    function withdrawFrom(
        address from,
        uint256 wad,
        address to
    ) public {
        require(balanceOf[from] >= wad);
        if (
            from != msg.sender &&
            allowance[from][msg.sender] != type(uint256).max &&
            !ProxyVerify.proveOwnerOf(msg.sender, from, userProxyDeployer)
        ) {
            require(allowance[from][msg.sender] >= wad);
            allowance[from][msg.sender] -= wad;
        }

        balanceOf[from] -= wad;
        payable(to).transfer(wad);
        emit Withdrawal(from, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.sender &&
            allowance[src][msg.sender] != type(uint256).max &&
            !ProxyVerify.proveOwnerOf(msg.sender, src, userProxyDeployer)
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}
