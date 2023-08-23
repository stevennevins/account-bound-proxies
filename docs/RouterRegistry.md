# RouterRegistry Contract

The RouterRegistry contract is used to manage the creation and retrieval of Router contracts. It uses the Clones library from OpenZeppelin to create deterministic clones of the Router contract.

## Functions

### createRouter

This function creates a new Router contract for the specified user. It emits a RouterCreated event upon successful creation of the Router contract.

### routerExistsFor

This function checks if a Router contract exists for the specified user. It returns true if a Router contract exists, false otherwise.

## User Interaction

The following sequence diagram shows how a user interacts with the RouterRegistry contract.

sequenceDiagram
    User->>RouterRegistry: createRouter(user)
    RouterRegistry-->>User: Transaction receipt (RouterCreated event)
    User->>RouterRegistry: routerExistsFor(user)
    RouterRegistry-->>User: Transaction receipt
    Router

