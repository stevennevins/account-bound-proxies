# MultiSendCallOnly Library

The MultiSendCallOnly library is used to batch multiple transactions into one. This allows for efficient execution of multiple transactions in a single call. The library is used by the Router contract to execute multiple transactions.

## Function

### multiSend

This function takes an encoded array of transactions and executes them. Each transaction is encoded as a packed bytes of operation, to, value, data length, and data. The function reverts if any of the transactions fail.

## User Interaction

Users interact with the MultiSendCallOnly library indirectly through the Router contract. The following sequence diagram shows how a user interacts with the Router contract, which uses the MultiSendCallOnly library.

sequenceDiagram
    User->>Router: multiSend(transactions)
    Router->>MultiSendCallOnly: multiSend(transactions)
    MultiSendCallOnly-->>Router: Transaction receipts
    Router-->>User: Transaction receipts

