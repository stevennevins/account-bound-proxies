# Account Bound Proxies

Account-Bound-Proxies provides a protocol-agnostic transaction batching mechanism to improve UX for EOA users. The goals of the smart contracts are:
 1. Improve the UX for EOA users
 2. Help protocol developers write simpler, safer, and more atomic interactions.

Inspired by earlier work done by @albertocuestacanada from yield protocol, specifically this article: https://hackernoon.com/using-the-forward-trust-design-pattern-to-make-scaling-easier, as well as @PaulRBerg work with PRB-Proxy, and DS-Proxy by dapphub

Proxies are intended to be compatible with https://github.com/gnosis/ethers-multisend
UX like -> https://github.com/morpho-labs/gnosis-tx-builder

## AccountBoundProxy.sol

The AccountBoundProxy.sol is a smart contract that acts as a proxy for executing multiple transactions. It is designed to be owned by a single address whose ownership is verifiable from a central onchain registry.

### Main functionalities of the Proxy contract:

- Ownership: The contract has an owner, set during the contract's creation as tx.origin. Only the owner can execute multisend functions or update the option plugin logic address.
- Plugin Logic: The contract has a plugin logic address, which is optional and can be utilized to enhance the functionality of the Proxy, i.e., Add onReceived hooks for NFTs
- Multi-Transaction Execution: The contract provides a function multiSend that allows the owner to execute multiple transactions in a single call. This function uses the multiSend function from the MultiSendCallOnly library which was adapted from Gnosis Safe and is intended to be fully compatible with the transaction encoding and decoding patterns they developed.

## ProxyRegistry.sol

The ProxyRegistry.sol is a smart contract that manages the creation, retrieval, and ownership verification of Proxy contracts.

### Main functionalities of the ProxyRegistry contract:

- Proxy Creation: The contract provides a function createProxy that creates a new AccountBoundProxy contract for a specified user. It uses the Create2 library to predict the address of the new AccountBoundProxy contract and checks if a contract already exists at that address. If not, it creates a new AccountBoundProxy contract and emits a ProxyCreated event.
- Proxy Existence Check: The contract provides a function proxyExistsFor that checks if an AccountBoundProxy contract exists for a specified user. It uses the Create2 library to predict the address of the AccountBoundProxy contract and checks if a contract exists at that address.
- Proxy Retrieval: The contract provides a function proxyFor that gets the address of the AccountBoundProxy contract for a specified user. It uses the Create2 library to predict the address of the Proxy contract.
- Proxy Ownership Check: The contract provides a function ownerOf that gets the owner of an AccountBoundProxy contract. It uses the IOwner interface to get the owner of the Proxy contract and checks if the owner matches the predicted owner.
