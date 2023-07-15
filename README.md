# Account Bound Routers

## Router.sol

The Router.sol is a smart contract that acts as a router and proxy for executing multiple transactions. It is designed to be owned by a single address and provides functionality to execute multiple transactions in a single call and to update the plugin logic address.

### Main functionalities of the Router contract:

- Ownership: The contract has an owner, which is set during the contract's creation in the constructor. The owner is retrieved from the cachedUser function of the IRegistryCallback interface implemented by the contract creator. Only the owner can execute certain functions, enforced by the onlyOwner modifier.
- Plugin Logic: The contract has a plugin logic address, which can be updated by the owner using the updatePluginLogic function. The plugin logic address is used as the implementation address in the inherited \_implementation function from the Proxy contract.
- Multi-Transaction Execution: The contract provides a function multiSend that allows the owner to execute multiple transactions in a single call. This function uses the multiSend function from the MultiSendCallOnly library.
- Fallback Functionality: The contract overrides the \_beforeFallback function from the Proxy contract. If the function signature matches the owner() function, it returns the owner's address. This allows external contracts to retrieve the owner's address without needing a separate function call.

## RouterRegistry.sol

The RouterRegistry.sol is a smart contract that manages the creation and retrieval of Router contracts. It provides functionalities to create a new Router contract for a user, check if a Router contract exists for a user, get the address of the Router contract for a user, and get the owner of a Router contract.

### Main functionalities of the RouterRegistry contract:

- Router Creation: The contract provides a function createRouter that creates a new Router contract for a specified user. It uses the Create2 library to predict the address of the new Router contract and checks if a contract already exists at that address. If not, it creates a new Router contract and emits a RouterCreated event.
- Router Existence Check: The contract provides a function routerExistsFor that checks if a Router contract exists for a specified user. It uses the Create2 library to predict the address of the Router contract and checks if a contract exists at that address.
- Router Retrieval: The contract provides a function routerFor that gets the address of the Router contract for a specified user. It uses the Create2 library to predict the address of the Router contract.
- Router Ownership Check: The contract provides a function ownerOf that gets the owner of a Router contract. It uses the IOwner interface to get the owner of the Router contract and checks if the owner matches the predicted owner.
