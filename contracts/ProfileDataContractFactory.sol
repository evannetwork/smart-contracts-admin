/*
  Copyright (C) 2018-present evan GmbH.

  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3,
  as published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program. If not, see http://www.gnu.org/licenses/ or
  write to the Free Software Foundation, Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA, 02110-1301 USA, or download the license from
  the following URL: https://evan.network/license/
*/

pragma solidity ~0.4.24;

import "./BaseContractFactory.sol";
import "./DSRolesPerContract.sol";
import "./DataContract.sol";


contract ProfileDataContractFactory is BaseContractFactory {
    uint public constant VERSION_ID = 2;
    
    function createContract(
            address businessCenter,
            address provider,
            bytes32 _contractDescription,
            address ensAddress) public returns (address) {
        // does not do anything, only kept to preserve interface support
    }

    function createContract(
            address businessCenter,
            address provider,
            bytes32 _contractDescription,
            address ensAddress,
            bytes32[] entries,
            bytes32[] lists) public returns (address) {
        DataContract newContract = new DataContract(provider, keccak256("ProfileDataContract"), _contractDescription, ensAddress);
        DSRolesPerContract roles = createRoles(provider, newContract, entries, lists);
        newContract.setAuthority(roles);
        bytes32 contractType = newContract.contractType();
        newContract.setOwner(provider);
        roles.setAuthority(roles);
        roles.setOwner(provider);
        ContractCreated(keccak256("ProfileDataContract"), newContract);
        return newContract;
    }

    function createRoles(address owner, address newContract, bytes32[] entries, bytes32[] lists
            ) public returns (DSRolesPerContract) {
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
        bytes32 setLabel = 0xd2f67e6aeaad1ab7487a680eb9d3363a597afa7a3de33fa9bf3ae6edcb88435d;

        uint256 i;
        uint8 propertyRole = 64;
        for (i = 0; i < entries.length; i++) {
            // give permission to owner role
            roles.setRoleOperationCapability(
                0, 0, keccak256(keccak256(0x84f3db82fb6cd291ed32c6f64f7f5eda656bda516d17c6bc146631a1f05a1833, entries[i]), setLabel), true);
            // give permission to specific role
            roles.setRoleOperationCapability(
                propertyRole, 0, keccak256(keccak256(0x84f3db82fb6cd291ed32c6f64f7f5eda656bda516d17c6bc146631a1f05a1833, entries[i]), setLabel), true);
            roles.setUserRole(owner, propertyRole, true);
            propertyRole = propertyRole + 1;
        }
        for (i = 0; i < lists.length; i++) {
            // give permission to owner role
            roles.setRoleOperationCapability(
                0, 0, keccak256(keccak256(0x7da2a80303fd8a8b312bb0f3403e22702ece25aa85a5e213371a770a74a50106, entries[i]), setLabel), true);
            // give permission to specific role
            roles.setRoleOperationCapability(
                propertyRole, 0, keccak256(keccak256(0x7da2a80303fd8a8b312bb0f3403e22702ece25aa85a5e213371a770a74a50106, entries[i]), setLabel), true);
            roles.setUserRole(owner, propertyRole, true);
            propertyRole = propertyRole + 1;
        }
        
        return roles;
    }
}
