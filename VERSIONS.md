# smart-contracts

## Next Version
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

## Version 0.1.0
- initial version