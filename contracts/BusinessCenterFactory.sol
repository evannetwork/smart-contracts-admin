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

import "./BusinessCenter.sol";
import "./DSRolesPerContract.sol";


/** @title Factory contract for creating contractus core components.*/
contract BusinessCenterFactory {
    event ContractCreated(address newAddress);

    /**@dev Creates a new business center.
     * @param rootDomain Hashed domain (e.g. namehash('contractus.eth')).
     * @return addr Address of the new business center.
     */
    function createContract(bytes32 rootDomain, address ensAddress) public returns (address addr) {
        BusinessCenter newBusinessCenter = new BusinessCenter(rootDomain, ensAddress);
        DSRolesPerContract roles = createRoles(newBusinessCenter);
        newBusinessCenter.setAuthority(roles);
        newBusinessCenter.transferOwnership(msg.sender);
        newBusinessCenter.setOwner(msg.sender);
        roles.setAuthority(roles);
        roles.setOwner(msg.sender);
        ContractCreated(newBusinessCenter);
        return newBusinessCenter;
    }

    function createRoles(address targetContract) private returns (DSRolesPerContract) {
        DSRolesPerContract roles = new DSRolesPerContract();
        address nullAddress = address(0);
        
        // roles
        uint8 ownerRole = 0;
        uint8 memberRole = 1;
        uint8 contractRole = 2;
        uint8 businessCenter = 3;
        uint8 factory = 4;

        // make contract root user of own roles config
        roles.setRootUser(targetContract, true);
        
        // user 2 role
        roles.setUserRole(msg.sender, ownerRole, true);
        roles.setUserRole(msg.sender, memberRole, true);
        roles.setUserRole(targetContract, businessCenter, true);
        
        // owner
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("getStorage()")), true);
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("init(address,uint8)")), true);
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("invite(address)")), true);
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("setJoinSchema(uint8)")), true);
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("migrateTo(address)")), true);
        roles.setRoleCapability(ownerRole, nullAddress, bytes4(keccak256("registerFactory(address)")), true);

        // members
        roles.setRoleCapability(memberRole, nullAddress, bytes4(keccak256("cancel()")), true);
        roles.setRoleCapability(memberRole, nullAddress, bytes4(keccak256("setMyProfile(bytes32)")), true);
        roles.setRoleCapability(memberRole, nullAddress, bytes4(keccak256("invite(address)")), true);

        // contracts 
        roles.setRoleCapability(contractRole, nullAddress,
            bytes4(keccak256("registerContractMember(address,address,bytes32)")), true);
        roles.setRoleCapability(contractRole, nullAddress,
            bytes4(keccak256("removeContractMember(address,address)")), true);
        roles.setRoleCapability(contractRole, nullAddress,
            bytes4(keccak256("sendContractEvent(uint256,bytes32,address)")), true);

        // businessCenter (self)
        roles.setRoleCapability(businessCenter, nullAddress,
            bytes4(keccak256("registerContractMember(address,address,bytes32)")), true);

        // factory
        roles.setRoleCapability(factory, nullAddress,
            bytes4(keccak256("registerContract(address,address,bytes32)")), true);

        return roles;
    }
}
