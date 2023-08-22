pragma solidity ^0.8.20;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Router.sol";
import "../contracts/lib/MultiSendCallOnly.sol";

contract RouterTest {
    Router router = Router(DeployedAddresses.Router());

    function testOwnerCanCall() public {
        bool r = router.updatePluginLogic(DeployedAddresses.Router());
        Assert.equal(r, true, "Owner should be able to call");
    }

    function testNonOwnerCannotCall() public {
        (bool r, ) = address(router).call(abi.encodePacked(router.updatePluginLogic.selector, DeployedAddresses.Router()));
        Assert.equal(r, false, "Non-owner should not be able to call");
    }

    function testMultiSendWithLargeTransactionBundles() public {
        bytes memory transactions = new bytes(10000);
        bool r = router.multiSend(transactions);
        Assert.equal(r, true, "Should be able to handle large transaction bundles");
    }
}

