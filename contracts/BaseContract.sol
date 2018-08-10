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
import "./BusinessCenterInterface.sol";
import "./DataContractInterface.sol";
import "./DSRolesPerContract.sol";
import "./EnsReader.sol";
import "./EventHubBusinessCenter.sol";
import "./ProfileIndexInterface.sol";


contract BaseContract is BaseContractInterface, EnsReader {
    uint8 private constant MEMBER_ROLE = 1;
    // web3.sha3('contacts')
    bytes32 private constant CONTACTS_LABEL = 0x8417ef2e3e7bb6630d90a4cdcc188db4bcc27d6b2d8891b376ef771499bb4299;
    // web3.sha3('eventhub')
    bytes32 private constant EVENTHUB_LABEL = 0xea14ea6d138254c1a2931c6a19f6888c7b52f512d165cfa428183a53dd9dfb8c;
    // web3.sha3('profile')
    bytes32 private constant PROFILE_LABEL = 0xe3dd854eb9d23c94680b3ec632b9072842365d9a702ab0df7da8bc398ee52c7d;

    function BaseContract(address _provider, bytes32 _contractType, bytes32 _contractDefinition, address ensAddress) {
        contractState = ContractState.Draft;
        created = now;
        contractType = _contractType;
        contractDefinition = _contractDefinition;
        consumerState[_provider] = ConsumerState.Draft;
        setEns(ensAddress);
    }

    function getProvider() constant returns (address provider) {
        return owner;
    }

    function changeConsumerState(address consumer, ConsumerState state) auth {
        ConsumerState currentState = consumerState[consumer];
        if (msg.sender == consumer) {
            if (currentState == ConsumerState.Initial && state == ConsumerState.Draft ||
                    currentState == ConsumerState.Draft && state == ConsumerState.Active ||
                    currentState == ConsumerState.Draft && state == ConsumerState.Rejected ||
                    state == ConsumerState.Terminated) {
                consumerState[msg.sender] = state;
                StateshiftEvent(uint(state), msg.sender);
            } else {
                assert(false);
            }
        } else {
            assert(isConsumer(consumer));
            if (currentState == ConsumerState.Initial && state == ConsumerState.Draft ||
                    state == ConsumerState.Terminated) {
                consumerState[consumer] = state;
                StateshiftEvent(uint(state), consumer);
            } else {
                assert(false);
            }
        }
    }

    function changeContractState(ContractState newState) auth {
        contractState = newState;
        StateshiftEvent(uint(newState), msg.sender);
    }

    function isConsumer(address consumer) constant returns (bool) {
        return consumer2index[consumer] != 0;
    }

    function getConsumerState(address consumer) constant returns (ConsumerState state) {
        return consumerState[consumer];
    }

    function getMyState() constant returns (ConsumerState state) {
        if (msg.sender == owner) {
            return ConsumerState.Active;
        } else {
            return consumerState[msg.sender];
        }
    }

    function inviteConsumer(address consumer, address businessCenter) {
        // throw if not owner and not allowConsumerInvite
        assert(msg.sender == owner || allowConsumerInvite);

        // throw if not owner and not member
        assert(msg.sender == owner || isConsumer(msg.sender));

        // thow if member and allowConsumerInvite disabled
        assert(msg.sender == owner || !isConsumer(msg.sender) || allowConsumerInvite);

        // throw if invitee doesn't know contact / blocks this user
        ProfileIndexInterface pIndex = ProfileIndexInterface(getAddr(PROFILE_LABEL));
        DataContractInterface profile = DataContractInterface(pIndex.getProfile(consumer));
        // if last bit is set, then invitee has set its known flag for msg.sender to true
        assert((profile.getMappingValue(CONTACTS_LABEL, keccak256(msg.sender)) & 1) == 1);


        if (businessCenter != 0x0) {
            BusinessCenterInterface businessCenterInterface = BusinessCenterInterface(businessCenter);
            assert(businessCenterInterface.isMember(consumer));
            assert(!isConsumer(consumer));
            businessCenterInterface.registerContractMember(this, consumer, contractType);
        } else {
            // trigger event from here if not attached to business businessCenter
            EventHubBusinessCenter eventHub = EventHubBusinessCenter(getAddr(EVENTHUB_LABEL));
            eventHub.sendContractEvent(
                uint(EventHubBusinessCenter.BusinessCenterEventType.New), contractType, this, consumer);
        }
        uint id = ++consumerCount;
        consumer2index[consumer] = id;
        index2consumer[id] = consumer;
        consumerState[consumer] = ConsumerState.Draft;

        // update permissions
        DSRolesPerContract roles = DSRolesPerContract(authority);
        roles.setUserRole(consumer, MEMBER_ROLE, true);
        StateshiftEvent(uint(ConsumerState.Draft), consumer);
    }

    function removeConsumer(address consumer) auth {
        assert(isConsumer(consumer));

        uint lastId = consumerCount--;
        uint idToOverwrite = consumer2index[consumer];

        index2consumer[idToOverwrite] = index2consumer[lastId];
        delete index2consumer[lastId];

        consumer2index[index2consumer[idToOverwrite]] = idToOverwrite;
        delete consumer2index[consumer];

        delete consumerState[consumer];

        DSRolesPerContract roles = DSRolesPerContract(authority);
        roles.setUserRole(consumer, MEMBER_ROLE, false);
    }
}
