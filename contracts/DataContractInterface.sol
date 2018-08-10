/*
  Copyright (C) 2018-present evan GmbH. 
  
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3, 
  as published by the Free Software Foundation. 
  
  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details. 
  
  You should have received a copy of the GNU Affero General Public License along with this program.
  If not, see http://www.gnu.org/licenses/ or write to the
  
  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA, 02110-1301 USA,
  
  or download the license from the following URL: https://evan.network/license/ 
  
  You can be released from the requirements of the GNU Affero General Public License
  by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts of it
  on other blockchains than evan.network. 
  
  For more information, please contact evan GmbH at this address: https://evan.network/license/ 
*/

pragma solidity 0.4.20;
import "./BaseContractInterface.sol";


/// @title Interface contract for generic data storage contracts, that can handle lists and entries
/// @author contractus GmbH
/// @notice this is a contract with abstract functions that is used as an interface for DataContracts
/// @dev implemtation most probably requires calling "init" before usage
contract DataContractInterface is BaseContractInterface {
    /// @notice add entries to a list
    /// @dev keep in mind that list do not provide a fixed order;
    /// they can be iterated, but deleting entries repositions items
    /// @param keys sha3 hash of the list name
    /// @param values values to add to this list
    function addListEntries(bytes32[] keys, bytes32[] values) public;

    /// @notice set the state of a consumer in the contract
    /// @dev shadows implementation of BaseContractInterface;
    /// can only follow state transitions defined in authority
    /// @param targetMember set state for this member
    /// @param newState state to set
    function changeConsumerState(address targetMember, ConsumerState newState) public;

    /// @notice update contract state
    /// @dev shadows implementation of BaseContractInterface;
    /// can only follow state transitions defined in authority
    /// @param newState state to set
    function changeContractState(ContractState newState) public;

    /// @notice setup basic contract structure; must be called before using this contract
    /// @param domain contractus root domain; is used for event hub lookups
    /// @param allowConsumerInviteIn allow other consumers to invite contract participants
    function init(bytes32 domain, bool allowConsumerInviteIn) public;

    /// @notice move a list entry from a list into one or multiple lists
    /// @param key sha3 hash of the list name
    /// @param index index of the element to delete
    /// @param keys sha3 hashes of the list names
    function moveListEntry(bytes32 key, uint256 index, bytes32[] keys) public;

    /// @notice remove a list entry from a list
    /// @dev moves last element from list into the slot where the deleted entry was placed
    /// @param key sha3 hash of the list name
    /// @param index index of the element to delete
    function removeListEntry(bytes32 key, uint256 index) public;

    /// @notice set a value of an entry in the contract
    /// @param key sha3 hash of a key
    /// @param value value to set for this key
    function setEntry(bytes32 key, bytes32 value) public;

    /// @notice set a value of a mapping property in the contract
    /// @param mappingHash sha3 hash of the mapping name
    /// @param key sha3 hash of the mappings entry/property name
    /// @param value value to set for this key
    function setMappingValue(bytes32 mappingHash, bytes32 key, bytes32 value) public;

    /// @notice retrieve entry value for a key
    /// @param key sha3 hash of a key
    /// @return value for this key
    function getEntry(bytes32 key) public constant returns(bytes32);

    /// @notice get number of elements in a list
    /// @param key sha3 hash of the list name
    /// @return number of elements
    function getListEntryCount(bytes32 key) public constant returns(uint256);

    /// @notice retrieve a single entry from a list
    /// @param key sha3 hash of the list name
    /// @param index index of the element to retrieve
    /// @return value for this list entry
    function getListEntry(bytes32 key, uint256 index) public constant returns(bytes32);

    /// @notice retrieve a single entry from a mapping
    /// @param mappingHash sha3 hash of the mapping name
    /// @param key sha3 hash of the mappings entry/property name
    /// @return value for this mapping entry
    function getMappingValue(bytes32 mappingHash, bytes32 key) public constant returns(bytes32);
}
