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

import "./BaseContract.sol";
import "./EventHubBusinessCenter.sol";
import "./ServiceContractInterface.sol";


contract ServiceContract is ServiceContractInterface, BaseContract {
    bytes32 public constant EVENTHUB_LABEL =
        0xea14ea6d138254c1a2931c6a19f6888c7b52f512d165cfa428183a53dd9dfb8c; //web3.sha3('events')

    function ServiceContract(address _provider, bytes32 _contractType, bytes32 _contractDefinition, address ensAddress) public
            BaseContract(_provider, _contractType, _contractDefinition, ensAddress) {
        contractState = ContractState.Draft;
        created = now;
    }

    function sendAnswer(bytes32 answerHash, uint256 callId) public {
        uint256 answerNumber = answersCountPerCall[callId]++;
        answersPerCall[callId][answerNumber] = answerHash;
    }
    
    function sendCall(bytes32 callHash) public {
        calls[callCount++] = callHash;
    }

    function setService(address _businessCenter, bytes32 hash) public auth in_state(ContractState.Draft) {
        service = hash;
        BusinessCenterInterface(_businessCenter).sendContractEvent(
            uint(EventHubBusinessCenter.BusinessCenterEventType.Modified), contractType, msg.sender);
    }
}
