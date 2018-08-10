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

import "./Defined.sol";
import "./Shared.sol";


contract BaseContractInterface is Defined, Shared {
    enum ContractState {
        Initial,
        Error,
        Draft,
        PendingApproval,
        Approved,
        Active,
        VerifyTerminated,
        Terminated
    }

    enum ConsumerState {
        Initial,
        Error,
        Draft,
        Rejected,
        Active,
        Terminated
    }

    ContractState public contractState;
    bytes32 public contractType;
    uint public created;
    uint public consumerCount;
    mapping(uint=>address) public index2consumer;
    mapping(address=>uint) public consumer2index;
    mapping (address => ConsumerState) public consumerState;
    bool public allowConsumerInvite;

    event StateshiftEvent(uint state, address indexed partner);

    function getProvider() public constant returns (address provider);
    function getConsumerState(address) public constant returns (ConsumerState);
    function getMyState() public constant returns (ConsumerState);
    function changeConsumerState(address, ConsumerState) public;
    function changeContractState(ContractState) public;
    function isConsumer(address) public constant returns (bool);
    function inviteConsumer(address, address) public;
    function removeConsumer(address) public;


    modifier in_state(ContractState _state) {
        assert(contractState == _state);
        _;
    }
    modifier not_in_state(ContractState _state) {
        assert(contractState != _state);
        _;
    }
}
