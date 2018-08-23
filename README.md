# smart-contracts-admin
## Contract Usage
### DataContract
Generic secured data storage contract for single properties and lists.


#### Permissions
Permissions are group based and have to be explicitly granted for function calls and so called "operations", which are actions that are performed on data in the contract.

Permissions are handled in the `DSRolesPerContract` contract and set as the `authority` in the DataContract. This is usually done in the contract factory, where the roles are created and assigned to the new contract instance.


##### Roles
Contract members are by default:

- owner (role 0)
- member (role 1)


##### Functions
Permissions for functions are set by allowing roles to use its signature, for example with

```
roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("init(bytes32,address,bool)")), true);
```


##### Operations
Operation permissions can be set in a similar way, by allowing roles to bytes32 keys. Exisitng key schemas can be found int "Lists", "Entries", "ContractStates" and "ConsumerStates"


#### Storing Data at the contract
##### Entries
###### Defining Entries
Entries are properties, that can allowed to use via permission config.

To allow the owner to set the property "ingredients-schema", this permission has to be granted:

```
roles.setRoleOperationCapability(
    ownerRole, 0, keccak256(keccak256(
    dc.ENTRY_LABEL(),
    keccak256("ingredients-schema")), dc.SET_LABEL()), true);
```

###### Using Entries
Set entries:
```
setEntry(bytes32 key, bytes32 value) public;
```

Get entries:
```
getEntry(bytes32 key) public constant returns(bytes32);
```


##### Lists
###### Defining List Entries
Lists are collections of entries, that can allowed to use via permission config.

To allow members to to add entries to the list 'ingredients', this permission has to be granted:

```
roles.setRoleOperationCapability(
    memberRole, 0, keccak256(keccak256(
    dc.LISTENTRY_LABEL(),
    keccak256("ingredients")), dc.SET_LABEL()), true);
```

To allow members to remove entries from this list, this permission has to be granted:

```
roles.setRoleOperationCapability(
    memberRole, 0, keccak256(keccak256(
    dc.LISTENTRY_LABEL(),
    keccak256("ingredients")), dc.REMOVE_LABEL()), true);
```


###### Using List Entries
Add list entries:
```
addListEntry(bytes32 key, bytes32 value) public;
```

Get list entries:
```
getListEntry(bytes32 key, uint256 index) public constant returns(bytes32);
```

To iterate over all list entries or display the count of list entries,
the number of elements has to be retrieved via:
```
getListCount(bytes32 key) public constant returns(uint256);
```


#### Contract States
The contracts state reflects the current state and how other members may be able to interact with it. So a Contract for tasks cannot have its tasks resolved, when the contract is still in Draft state. State transitions are limited to configured roles and allow going from one state to another only if configured for this role.

To implement a simple workflow like:
```
+---------+     +-------+     +--------+     +------------+
| Initial | --> | Draft | --> | Active | --> | Terminated |
+---------+     +-------+     +--------+     +------------+
```

Make sure, you add this to your authority setup:
```solidity
roles.setRoleOperationCapability(
    ownerRole, 0, keccak256(keccak256(
    dc.CONTRACTSTATE_LABEL(),
    BaseContractInterface.ContractState.Initial),
    BaseContractInterface.ContractState.Draft), true);
roles.setRoleOperationCapability(
    ownerRole, 0, keccak256(keccak256(
    dc.CONTRACTSTATE_LABEL(),
    BaseContractInterface.ContractState.Draft),
    BaseContractInterface.ContractState.Active), true);
roles.setRoleOperationCapability(
    ownerRole, 0, keccak256(keccak256(
    dc.CONTRACTSTATE_LABEL(),
    BaseContractInterface.ContractState.Active),
    BaseContractInterface.ContractState.Terminated), true);
```

The contract state can be set via :
```solidity
function changeContractState(ContractState newState);
```


#### Consumer States
A members state reflects this members status in the contract. These status values can for example be be Active, Draft or Terminated. These states are similar to a state machine, only transitions permitted in the contracts can be used.

For example a simple flow with these transitions:
```
+----------+     +--------+     +------------+
|  Draft   | --> | Active | --> | Terminated |
+----------+     +--------+     +------------+
  |
  |
  v
+----------+
| Rejected |
+----------+
```

Can be configured with:
```solidity
roles.setRoleOperationCapability(
    memberRole, 0, keccak256(keccak256(
    dc.OWNSTATE_LABEL(), BaseContractInterface.ConsumerState.Draft),
    BaseContractInterface.ConsumerState.Rejected), true);
roles.setRoleOperationCapability(
    memberRole, 0, keccak256(keccak256(
    dc.OWNSTATE_LABEL(), BaseContractInterface.ConsumerState.Draft),
    BaseContractInterface.ConsumerState.Active), true);
roles.setRoleOperationCapability(
    memberRole, 0, keccak256(keccak256(
    dc.OWNSTATE_LABEL(),
    BaseContractInterface.ConsumerState.Active),
    BaseContractInterface.ConsumerState.Terminated), true);
```

Depending on its role, users may traverse different states, so a contract owner can have another workflow than a contract member.

Depending on the permission config, some roles may be able to update roles of other users, e.g. an owner may be able to set new members from Initial to Draft.

Consumer state can be set via:
```solidity
function changeConsumerState(address consumer, ConsumerState state);
```

Depending on whether the given consumer address matches or not the checks defined above are applied.


#### Example Project
This section describes how to setup a factory for using the DataContract as a TaskList contract. An implementation that follows this schema can be found in the `TaskDataContractFactory.sol` contract.

##### Setting up Permissions
- owner of a task contract should be able to add ToDos ("todos")
    ```
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.LISTENTRY_LABEL(),
        keccak256("todos")), dc.SET_LABEL()), true);
    ```

- member in the contract should be able to add logs about the ToDos ("todologs")
    ```
    roles.setRoleOperationCapability(
        memberRole, 0, keccak256(keccak256(
        dc.LISTENTRY_LABEL(),
        keccak256("todologs")), dc.SET_LABEL()), true);
    ```

- schemas for both lists have to be saved at the contract by the owner
    ```
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.ENTRY_LABEL(),
        keccak256("todos-schema")), dc.SET_LABEL()), true);
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.ENTRY_LABEL(),
        keccak256("todologs-schema")), dc.SET_LABEL()), true);
    ```

- to be able to use the appropriate contract functions, these permissions have to be granted for the contract functions as well:
    - owner has to be able to set entries
    `roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("setEntry(bytes32,bytes32)")), true);`
    - member (which includes the owner per default) have to be able to add list entries
    `roles.setRoleCapability(memberRole, 0, bytes4(keccak256("addListEntry(bytes32,bytes32)")), true);`

- the owner should be allowed to update the contract state from Initial to Draft, then to Active and then to Terminated, so contract states are configured as:
    ```
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Initial),
        BaseContractInterface.ContractState.Draft), true);
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Draft),
        BaseContractInterface.ContractState.Active), true);
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Active),
        BaseContractInterface.ContractState.Terminated), true);
    ```

- members can update their own status from Draft to Active or Rejected and from Active to Terminated, so the own-state config looks like:
    ```
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Initial),
        BaseContractInterface.ContractState.Draft), true);
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Draft),
        BaseContractInterface.ContractState.Active), true);
    roles.setRoleOperationCapability(
        ownerRole, 0, keccak256(keccak256(
        dc.CONTRACTSTATE_LABEL(),
        BaseContractInterface.ContractState.Active),
        BaseContractInterface.ContractState.Terminated), true);
    ```

- after the roles instance is set as the authority in the DataContract, the owner cat add new tasks with `addListEntry(keccak256("todos"), value)` and member can add logs about the tasks via `addListEntry(keccak256("todologs"), value)`


## Documentation
A sample script for building documentation for smart contracts via [soldoc](https://github.com/dev-matan-tsuberi/soldoc)<sup>[+]</sup> has been added, run it via

```
npm run build-docu
```

If used with default soldoc setup, this will most probably fail, as soldoc does not differ between Warnings and Errors, leading to ignoring to successful contract compilations with warnings and treating those as failed builds. As a workaround for this, open `./node_modules/@soldoc/soldoc/index.js` and comment out the lines (about line 16)

```
if(result.errors)
    reject(new Error(result.errors));
```
