# IOwner Interface

The IOwner interface defines a single function, `owner()`, which is used to get the owner of a contract. This interface can be implemented by any contract that needs to have an owner.

## Function

### owner

This function returns the address of the owner of the contract. It is a view function, meaning it does not modify the state of the contract.

## User Interaction

The following sequence diagram shows how a user interacts with a contract that implements the IOwner interface.

sequenceDiagram
    User->>IOwner: owner()
    IOwner->>User: Address of the contract owner

