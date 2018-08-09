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
import "./DataContract.sol";


contract ProfileDataContractFactory is BaseContractFactory {
    uint public constant VERSION_ID = 1;

    function createContract(address businessCenter, address provider, bytes32 _contractDescription, address ensAddress
            ) public returns (address) {
        DataContract newContract = new DataContract(provider, keccak256("ProfileDataContract"), _contractDescription, ensAddress);
        DSRolesPerContract roles = createRoles(provider, newContract);
        newContract.setAuthority(roles);
        bytes32 contractType = newContract.contractType();
        newContract.setOwner(provider);
        roles.setAuthority(roles);
        roles.setOwner(provider);
        ContractCreated(keccak256("ProfileDataContract"), newContract);
        return newContract;
    }

    function createRoles(address owner, address newContract) public returns (DSRolesPerContract) {
        DSRolesPerContract roles = super.createRoles(owner);
        DataContract dc = DataContract(newContract);
        // roles
        uint8 ownerRole = 0;

        // make contract root user of own roles config
        roles.setRootUser(newContract, true);

        // role 1 permission
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("init(bytes32,bool)")), true);
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("setEntry(bytes32,bytes32)")), true);
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("addListEntries(bytes32[],bytes32[])")), true);

        // owner operation permission
        // entries
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("addressBook")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("bookmarkedDapps")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("contracts")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.MAPPINGENTRY_LABEL(),
            keccak256("contacts")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("publicKey")), dc.SET_LABEL()), true);
        
        return roles;
    }
}
