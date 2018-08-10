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

import "./Core.sol";
import "./DataStoreIndex.sol";


contract BusinessCenterInterface is Owned {
    enum JoinSchema { SelfJoin, AddOnly, Handshake, JoinOrAdd }

    uint public VERSION_ID;
    JoinSchema public joinSchema;
    mapping(address => bool) public pendingJoins;
    mapping(address => bool) public pendingInvites;

    modifier only_members {
        assert(isMember(msg.sender));
        _;
    }

    function init(DataStoreIndex, JoinSchema) public;

    function join() public;
    function invite(address) public;
    function cancel() public;

    function registerContract(address _contract, address _provider, bytes32 _contractType) public;
    function registerContractMember(address _contract, address _member, bytes32 _contractType) public;
    function removeContractMember(address _contract, address _member) public;
    function migrateTo(address) public;
    function sendContractEvent(uint evetType, bytes32 contractType, address member) public;
    function getProfile(address account) public constant returns (bytes32);
    function setMyProfile(bytes32 profile) public;
    function setJoinSchema(JoinSchema) public;

    function isMember(address _member) public constant returns (bool);
    function isContract(address _contract) public constant returns (bool);
    function getMyIndex() public constant returns (DataStoreIndex);
    function getStorage() public constant returns (DataStoreIndex);
}
