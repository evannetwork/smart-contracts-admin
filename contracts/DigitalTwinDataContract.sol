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
import "./BaseContractInterface.sol";
import "./DSRolesPerContract.sol";
import "./DataContract.sol";


contract DigitalTwinDataContractFactory is BaseContractFactory {
    uint public constant VERSION_ID = 3;

    function createContract(address businessCenter, address provider, bytes32 _contractDescription, address ensAddress
            ) public returns (address) {
        DataContract newContract = new DataContract(provider, keccak256("DigitalTwinDataContract"), _contractDescription, ensAddress);
        DSRolesPerContract roles = createRoles(provider, newContract);
        newContract.setAuthority(roles);
        bytes32 contractType = newContract.contractType();
        super.registerContract(businessCenter, newContract, provider, contractType);
        newContract.setOwner(provider);
        roles.setAuthority(roles);
        roles.setOwner(provider);
        ContractCreated(keccak256("DigitalTwinDataContract"), newContract);
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
        roles.setRoleCapability(ownerRole, 0, bytes4(keccak256("init(bytes32,bool)")), true);
        // member permissions
        roles.setRoleCapability(memberRole, 0, bytes4(keccak256("addListEntries(bytes32[],bytes32[])")), true);
        roles.setRoleCapability(memberRole, 0, bytes4(keccak256("moveListEntry(bytes32,uint256,bytes32[])")), true);
        roles.setRoleCapability(memberRole, 0, bytes4(keccak256("removeListEntry(bytes32,uint256)")), true);
        roles.setRoleCapability(memberRole, 0, bytes4(keccak256("setEntry(bytes32,bytes32)")), true);

        // role 2 operation permission
        // entries
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.ENTRY_LABEL(),
            keccak256("technicalData")), dc.SET_LABEL()), true);
        // lists
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("rentalContracts")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("rentalContracts")), dc.REMOVE_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("tasks")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("tasks")), dc.REMOVE_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("activities")), dc.SET_LABEL()), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.LISTENTRY_LABEL(),
            keccak256("activities")), dc.REMOVE_LABEL()), true);

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
            BaseContractInterface.ContractState.PendingApproval), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.PendingApproval),
            BaseContractInterface.ContractState.Draft), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.PendingApproval),
            BaseContractInterface.ContractState.Approved), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Approved),
            BaseContractInterface.ContractState.Active), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Approved),
            BaseContractInterface.ContractState.Terminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.Active),
            BaseContractInterface.ContractState.VerifyTerminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.VerifyTerminated),
            BaseContractInterface.ContractState.Terminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.CONTRACTSTATE_LABEL(),
            BaseContractInterface.ContractState.VerifyTerminated),
            BaseContractInterface.ContractState.Active), true);

        // member states (own)
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Initial),
            BaseContractInterface.ConsumerState.Draft), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Rejected), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Active), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            dc.OWNSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Active),
            BaseContractInterface.ConsumerState.Terminated), true);

        // member states (other members)
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            dc.OTHERSSTATE_LABEL(),
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Terminated), true);

        return roles;
    }
}
