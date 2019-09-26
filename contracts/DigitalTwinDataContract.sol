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
        bytes32 setLabel = 0xd2f67e6aeaad1ab7487a680eb9d3363a597afa7a3de33fa9bf3ae6edcb88435d;
        bytes32 removeLabel = 0x8dd27a19ebb249760a6490a8d33442a54b5c3c8504068964b74388bfe83458be;
        bytes32 listentryLabel = 0x7da2a80303fd8a8b312bb0f3403e22702ece25aa85a5e213371a770a74a50106;
        bytes32 contractstateLabel = 0xf0af2cee3e7130dfb5ef02ebfaf64a30da17e9c9c26d3d40ece69a2e0ee1d69e;
        bytes32 ownstateLabel = 0x56ead3438bd16b0aaea9b0b78119b1db8a5382b496db7a1989fe7a32f9890f7c;
        // entries
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            0x84f3db82fb6cd291ed32c6f64f7f5eda656bda516d17c6bc146631a1f05a1833,
            keccak256("technicalData")), setLabel), true);
        // lists
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("rentalContracts")), setLabel), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("rentalContracts")), removeLabel), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("tasks")), setLabel), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("tasks")), removeLabel), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("activities")), setLabel), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            listentryLabel,
            keccak256("activities")), removeLabel), true);

        // contract states
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.Initial),
            BaseContractInterface.ContractState.Draft), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.Draft),
            BaseContractInterface.ContractState.PendingApproval), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.PendingApproval),
            BaseContractInterface.ContractState.Draft), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.PendingApproval),
            BaseContractInterface.ContractState.Approved), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.Approved),
            BaseContractInterface.ContractState.Active), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.Approved),
            BaseContractInterface.ContractState.Terminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.Active),
            BaseContractInterface.ContractState.VerifyTerminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.VerifyTerminated),
            BaseContractInterface.ContractState.Terminated), true);
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            contractstateLabel,
            BaseContractInterface.ContractState.VerifyTerminated),
            BaseContractInterface.ContractState.Active), true);

        // member states (own)
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            ownstateLabel,
            BaseContractInterface.ConsumerState.Initial),
            BaseContractInterface.ConsumerState.Draft), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            ownstateLabel,
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Rejected), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            ownstateLabel,
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Active), true);
        roles.setRoleOperationCapability(
            memberRole, 0, keccak256(keccak256(
            ownstateLabel,
            BaseContractInterface.ConsumerState.Active),
            BaseContractInterface.ConsumerState.Terminated), true);

        // member states (other members)
        roles.setRoleOperationCapability(
            ownerRole, 0, keccak256(keccak256(
            0xa287c88bf56474b8c2de2568111316e26d1b3572718b1a8cdf0c881a767e4cb7,
            BaseContractInterface.ConsumerState.Draft),
            BaseContractInterface.ConsumerState.Terminated), true);

        return roles;
    }
}
