# smart-contracts-admin

## Next Version
### Features

### Fixes

### Deprecations


## Version 2.2.0
### Features
- add `requestOwnerTicket` to `TicketVendor`


## Version 2.1.0
### Features
- add automatic query repetition to `TicketVendor`
- add support for templates to profiles


## Version 2.0.0
### Features
- use updated contracts with lesser execution cost from `smart-contracts-core`
- replace labels from `DataContract` with pregenerated hashes to save gas cost

### Fixes
- add `auth` modifier to `addExtraReceiver`


## Version 1.3.0
### Features
- add BlockReward and Validator contracts for Mainnet
- set profile contact knows state active for mailbox

## Version 1.2.0
### Features
- add `TicketVendor`, that allows to create EVE exchange tickets for bridge
- change name and output of `getContractsPath` (--> `getContractPaths`) in `index.js`, usage requires `smart-contracts-core`  with version > `1.1.1`
- add script for installing additional dependencies like
  + oraclize API
  + string-utilities
- update `TicketVendor`
  + remove responsibilities for ticket validity
    * remove `consumeTicket`
    * remove `setMinValue`, `getMinValue`
  + use `eveWeiPerEther` for price related info (read as "EVE Wei" per "(mainnet) Ether")
  + update `updatePrice` to fail is missing funds for query callback

## Version 1.1.0
### Features
- add `MailBoxInterface` as parent contract for `MailBox`
- add `ClaimsENS.sol` and `ClaimsPublicResolver.sol` for managing claims on-chain
- use `keccak256` instead of `sha3` for hashing

## Version 1.0.2
### Features
- add minimum permissions to `TransactionPermissionContract.sol`, that allow to define minimum permissions for all accounts (even if not added to contracts permitted object)

### Fixes

### Deprecations
- rename project to `@evan-network/smart-contracts-admin`
- move core contracts and compile logic into `@evan-network/smart-contracts-core`


## Version 1.0.1
### Features
- use @evan.network for package name and dependencies scopes
- add `TransactionPermissionContract.sol` for checking if accounts are allowed to perform transactions
- add Parity Registry and Certifier related contracts
- allow the owner of `ProfileIndex.sol` to set profiles for other accounts

### Deprecations
- remove Defined.sol as it isn't longer in use (artifact from name cleanup)

## Version 1.0.0
- add support for passing multiple folders to compileContracts (in addition default folder and ens folder)
- add docu for DataContract and sample contract (TaskDataContractFactory.sol)
- add note on how to build docu files (including the workaround for solc warnings)
- replace DataContract.addListEntry with addListEntries that adds multiple bytes32 value
- move ENS from contract init in specific contracts to BaseContractConstructor
- allow BaseContracts to be created without BusinessCenter
- update DataContract.addListEntries to support multiple keys
- add DataContract.moveListEntry function
- update DataContractEvent to publish multple keys
- updae error filter in compile step to properly fail on documentation errors
- smart contract factories now assign the created contracts root user permissions to its own permissions
- smart contract factories now transfer ownership of the permissions of new contracts to the contract creator
- permissions in contracts from smart contract factories are now their own authority
- ENS contract files are included in loading logic by default, as they are a requirement by now
- remove AssetContract from contracts, as it is no longer supported by API
- add `setMappingValue` and `setMappingValue` to `DataContract` contract for setting properties, that are mappings and manage their own key value mappings
- rewrite `Mailbox.withdrawFromMail` to require a target account when withdrawing
- forbid inviting consumers into contracts, when consumer does not know inviter (or has blocked this account)

## Version 0.9.0
- initial version and release candidate for 1.0.0
