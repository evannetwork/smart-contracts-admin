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

pragma solidity ^0.4.18;

import './ENS.sol';
import './Core.sol';

/**
 * A registrar that allocates subdomains to the first person to claim them.
 */
contract OwnedRegistrar is Owned {
    ENS ens;
    bytes32 rootNode;

    /**
     * Constructor.
     * @param ensAddr The address of the ENS registry.
     * @param node The node that this registrar administers.
     */
    function OwnedRegistrar(ENS ensAddr, bytes32 node) public {
        ens = ensAddr;
        rootNode = node;
    }

    /**
     * Register a name, or change the owner of an existing registration.
     * @param subnode The hash of the label to register.
     * @param newOwner The address of the new owner.
     */
    function register(bytes32 subnode, address newOwner) public only_owner {
        ens.setSubnodeOwner(rootNode, subnode, newOwner);
    }

    /**
     * Set the owner of the rootNode back to the owner of the registrar
     */
    function setRootNodeOwner() public only_owner {
        ens.setOwner(rootNode, owner);
    }    
}