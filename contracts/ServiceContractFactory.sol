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

import "./BaseContractFactory.sol";
import "./DSRolesPerContract.sol";
import "./ServiceContract.sol";


contract ServiceContractFactory is BaseContractFactory {
    uint public VERSION_ID = 2;

    function createContract(address businessCenter, address provider, bytes32 contractDefinition, address ensAddress) public returns (address) {
        ServiceContract newContract = new ServiceContract(provider, keccak256("ServiceContract"), contractDefinition, ensAddress);
        DSRolesPerContract roles = createRoles(provider);
        newContract.setAuthority(roles);
        bytes32 contractType = newContract.contractType();
        super.registerContract(businessCenter, newContract, provider, contractType);
        newContract.setOwner(provider);
        roles.setOwner(newContract);
        ContractCreated(keccak256("ServiceContract"), newContract);
        return newContract;
    }

    function createRoles(address owner) public returns (DSRolesPerContract) {
        DSRolesPerContract roles = super.createRoles(owner);
        // roles
        uint8 memberRole = 1;

        // role 2 permission
        // owner
        roles.setRoleCapability(memberRole, msg.sender,
            bytes4(keccak256("addService(address,string,string,string)")), true);
        // member
        roles.setRoleCapability(memberRole, msg.sender, bytes4(keccak256("getServiceUrl(string)")), true);
        roles.setRoleCapability(memberRole, msg.sender, bytes4(keccak256("getServiceHash(string)")), true);

        return roles;
    }
}
