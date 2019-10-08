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
        bytes32 setLabel = 0xd2f67e6aeaad1ab7487a680eb9d3363a597afa7a3de33fa9bf3ae6edcb88435d;
        bytes32 entryLabel = 0x84f3db82fb6cd291ed32c6f64f7f5eda656bda516d17c6bc146631a1f05a1833;
        bytes32 mappingentryLabel = 0xd9234c2c276ff426c50a259dd40abb4cdd9767973f4a72f6e032e829f681e0b4;
        // entries
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            entryLabel,
            keccak256("addressBook")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            entryLabel,
            keccak256("bookmarkedDapps")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            entryLabel,
            keccak256("contracts")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            mappingentryLabel,
            keccak256("contacts")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            mappingentryLabel,
            keccak256("profileOptions")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            entryLabel,
            keccak256("publicKey")), setLabel), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            mappingentryLabel,
            keccak256("templates")), setLabel), true);
        
        return roles;
    }
}
