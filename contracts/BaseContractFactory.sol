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

import "./BaseContractFactoryInterface.sol";
import "./BusinessCenterInterface.sol";
import "./DSRolesPerContract.sol";


contract BaseContractFactory is BaseContractFactoryInterface {
    uint public VERSION_ID;

    event ContractCreated(bytes32 contractInfo, address newAddress);

    function createContract(address businessCenter, address provider, bytes32 contractDefinition, address ensAddress)
        public returns (address);

    function createRoles(address owner) public returns (DSRolesPerContract) {
        DSRolesPerContract roles = new DSRolesPerContract();
        address nullAddress = address(0);

        // roles
        uint8 ownerRole = 0;
        uint8 memberRole = 1;
        
        // user 2 role
        roles.setUserRole(owner, ownerRole, true);
        roles.setUserRole(owner, memberRole, true);
        
        // owner
        roles.setRoleCapability(ownerRole, nullAddress, 
            bytes4(keccak256("changeContractState(uint8)")), true);
        roles.setRoleCapability(ownerRole, nullAddress,
            bytes4(keccak256("removeConsumer()")), true);

        // member           
        roles.setRoleCapability(memberRole, nullAddress, 
            bytes4(keccak256("changeConsumerState(address,uint8)")), true);

        
        return roles;
    }

    function registerContract(
            address businessCenter, address _contract, address _provider, bytes32 _contractType) public {
        if (businessCenter != 0x0) {
            BusinessCenterInterface(businessCenter).registerContract(_contract, _provider, _contractType);
        }
    }
}
