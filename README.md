# EOA Bound Routers

Externally owned account(EOA)-Bound-Routers provides a protocol agnostic transaction batching mechanism to improve UX for EOA users. The goal of the smart contracts are:
 1. Improve the UX for EOA users
 2. Help protocol developers write simpler, safer, and more atomic interactions.

Inspired by earlier work done by @albertocuestacanada from yield protocol, specifically this article: https://hackernoon.com/using-the-forward-trust-design-pattern-to-make-scaling-easier, as well as @PaulRBerg work with PRB-Proxy, and DS-Proxy by dapphub

Routers are intended to be compatible with https://github.com/gnosis/ethers-multisend

## Router.sol

The Router.sol is a smart contract that acts as a router and proxy for executing multiple transactions. It is designed to be owned by a single address whose ownership is verifiable from a central onchain registry.

### Main functionalities of the Router contract:

- Ownership: The contract has an owner, set during the contract's creation as tx.origin. Only the owner can execute multisend functions or update the option plugin logic address.
- Plugin Logic: The contract has a plugin logic address, which is optional and can be utilized to enhance the functionality of the router, ie Add onReceived hooks for NFTs
- Multi-Transaction Execution: The contract provides a function multiSend that allows the owner to execute multiple transactions in a single call. This function uses the multiSend function from the MultiSendCallOnly library which was adapted from Gnosis Safe and is intended to be fully compatible with the transaction encoding and decoding patterns they developed.

## RouterRegistry.sol

The RouterRegistry.sol is a smart contract that manages the creation, retrieval, and ownership verification of Router contracts.

### Main functionalities of the RouterRegistry contract:

- Router Creation: The contract provides a function createRouter that creates a new Router contract for a specified user. It uses the Create2 library to predict the address of the new Router contract and checks if a contract already exists at that address. If not, it creates a new Router contract and emits a RouterCreated event.
- Router Existence Check: The contract provides a function routerExistsFor that checks if a Router contract exists for a specified user. It uses the Create2 library to predict the address of the Router contract and checks if a contract exists at that address.
- Router Retrieval: The contract provides a function routerFor that gets the address of the Router contract for a specified user. It uses the Create2 library to predict the address of the Router contract.
- Router Ownership Check: The contract provides a function ownerOf that gets the owner of a Router contract. It uses the IOwner interface to get the owner of the Router contract and checks if the owner matches the predicted owner.
