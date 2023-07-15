// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum Operation {
    Call,
    DelegateCall
}

struct Transaction {
    address to;
    uint256 value;
    bytes data;
    Operation operation;
}

contract EncodeTxs {
    function encode(Transaction[] memory txs) internal pure returns (bytes memory data) {
        require(txs.length > 0, "no txs to encode");
        for (uint256 i; i < txs.length; i++) {
            require(txs[i].operation == Operation.Call, "only call");
            data = abi.encodePacked(
                data,
                abi.encodePacked(
                    uint8(txs[i].operation),
                    /// operation as an uint8.
                    txs[i].to,
                    /// to as an address.
                    txs[i].value,
                    /// value as an uint256.
                    uint256(txs[i].data.length),
                    /// data length as an uint256.
                    txs[i].data
                )
            );
            /// data as bytes.
        }
    }
}
