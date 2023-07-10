// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Proxy} from "src/Proxy.sol";
import {ProxyFactory} from "src/ProxyFactory.sol";
import {EncodeTxs, Transaction, Operation} from "test/helpers/EncodeTx.sol";
import {FWETH} from "test/examples/FWETH.sol";
import {WETH9} from "test/examples/WETH9.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {MockPullWETH} from "test/examples/mocks/MockPullWETH.sol";

contract FWETHTest is EncodeTxs, Test {
    ProxyFactory internal factory = new ProxyFactory();
    WETH9 internal weth9 = new WETH9();
    address internal owner = address(2);
    FWETH internal fweth;
    Transaction[] internal txs;
    Proxy internal proxy;
    MockPullWETH internal puller;

    function setUp() public {
        factory.createProxy(owner);
        proxy = Proxy(payable(getProxyAddress(owner)));
        fweth = new FWETH(address(factory));
    }

    function test_EOA_WETH9() public {
        puller = new MockPullWETH(address(weth9));
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        weth9.deposit{value: 1 ether}();
        weth9.approve(address(puller), type(uint256).max);
        puller.depositWETH(1 ether);
        vm.stopPrank();
    }

    function test_Multisend_WETH9() public {
        puller = new MockPullWETH(address(weth9));
        txs.push(
            Transaction(
                address(weth9),
                1 ether,
                abi.encodeCall(WETH9.deposit, ()),
                Operation.Call
            )
        );
        txs.push(
            Transaction(
                address(weth9),
                0,
                abi.encodeCall(
                    WETH9.approve,
                    (address(puller), type(uint256).max)
                ),
                Operation.Call
            )
        );
        txs.push(
            Transaction(
                address(puller),
                0,
                abi.encodeCall(MockPullWETH.depositWETH, (1 ether)),
                Operation.Call
            )
        );

        vm.deal(owner, 1 ether);
        vm.prank(owner);
        proxy.multiSend{value: 1 ether}(encode(txs));
    }

    function test_EOA_FWETH() public {
        puller = new MockPullWETH(address(fweth));
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);
        fweth.depositTo{value: 1 ether}(owner);
        fweth.approve(address(puller), type(uint256).max);
        puller.depositWETH(1 ether);
        vm.stopPrank();
    }

    function test_Multisend_FWETH() public {
        puller = new MockPullWETH(address(fweth));
        txs.push(
            Transaction(
                address(fweth),
                1 ether,
                abi.encodeCall(FWETH.depositTo, (address(proxy))),
                Operation.Call
            )
        );
        txs.push(
            Transaction(
                address(fweth),
                0,
                abi.encodeCall(
                    FWETH.approve,
                    (address(puller), type(uint256).max)
                ),
                Operation.Call
            )
        );
        txs.push(
            Transaction(
                address(puller),
                0,
                abi.encodeCall(MockPullWETH.depositWETH, (1 ether)),
                Operation.Call
            )
        );

        vm.deal(owner, 1 ether);
        vm.prank(owner);
        proxy.multiSend{value: 1 ether}(encode(txs));
    }

    function getProxyAddress(address _user) internal view returns (address) {
        address userProxy = Create2.computeAddress(
            keccak256(abi.encode(_user)),
            factory.initCodeHash(),
            address(factory)
        );
        require(userProxy.code.length > 0, "no code");
        return userProxy;
    }
}
