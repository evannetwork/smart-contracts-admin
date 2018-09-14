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

  You can be released from the requirements of the GNU Affero General Public
  License by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts
  of it on other blockchains than evan.network.

  For more information, please contact evan GmbH at this address:
  https://evan.network/license/
*/

pragma solidity 0.4.20;

import "./BaseContractFactory.sol";
import "./BaseContractInterface.sol";
import "./DSRolesPerContract.sol";
import "./DataContract.sol";


contract TaskDataContractFactory is BaseContractFactory {
    uint public constant VERSION_ID = 3;

    function createContract(address businessCenter, address provider, bytes32 _contractDescription, address ensAddress
            ) public returns (address) {
        DataContract newContract = new DataContract(provider, keccak256("TaskDataContract"), _contractDescription, ensAddress);
        DSRolesPerContract roles = createRoles(provider, newContract);
        newContract.setAuthority(roles);
        bytes32 contractType = newContract.contractType();
        super.registerContract(businessCenter, newContract, provider, contractType);
        newContract.setOwner(provider);
        roles.setAuthority(roles);
        roles.setOwner(provider);
        ContractCreated(keccak256("TaskDataContract"), newContract);
        return newContract;
    }

    function createRoles(address owner, address newContract) public returns (DSRolesPerContract) {
        DSRolesPerContract roles = super.createRoles(owner);
        DataContract dc = DataContract(newContract);
        // roles
        uint8 ownerRole = 0;
        uint8 memberRole = 1;

        // make contract root user of own roles config
        roles.setRootUser(newContract, true);

        // role 2 permission
        // owner
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("init(bytes32,bool)")), true);
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("setEntry(bytes32,bytes32)")), true);
        // member
        roles.setRoleCapability(memberRole, 0, bytes4(keccak256("addListEntries(bytes32[],bytes32[])")), true);

        // role 2 operation permission
        // schemas
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("metadata")), dc.SET_LABEL()), true);
        
        // data lists
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("todos")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("todologs")), dc.SET_LABEL()), true);

        // contract states
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Initial),
            BaseContractInterface.ContractState.Draft), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Draft),
            BaseContractInterface.ContractState.Active), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Active),
            BaseContractInterface.ContractState.Terminated), true);

        // member states (own)
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(), BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Rejected), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(), BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Active), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Active),
            BaseContractInterface.ConsumerState.Terminated), true);

        // member states (other members)
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(keccak256(
            dc.OTHERSSTATE_LABEL(), BaseContractInterface.ConsumerState.Initial),
            BaseContractInterface.ConsumerState.Draft), memberRole), true);

        return roles;
    }
}
