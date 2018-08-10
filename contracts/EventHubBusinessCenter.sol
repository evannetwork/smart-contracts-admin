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


contract EventHubBusinessCenter {

    enum BusinessCenterEventType {
        New,
        Cancel,
        Draft,
        Rejected,
        Approved,
        Active,
        Terminated,
        Invite,
        Modified,
        PendingJoin,
        PendingInvite
    }

    event ContractEvent(
        address sender,
        uint eventType,
        bytes32 indexed contractType,
        address indexed contractAddress,
        address indexed member);

    event MemberEvent(address sender, uint eventType, address indexed member);

    function sendContractEvent(uint eventType, bytes32 contractType, address contractAddress, address member) public {
        ContractEvent(msg.sender, eventType, contractType, contractAddress, member);
    }

    function sendMemberEvent(uint eventType, address member) public {
        MemberEvent(msg.sender, eventType, member);
    }
}
