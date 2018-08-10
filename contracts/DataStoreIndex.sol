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

pragma solidity ^0.4.0;

import "./DataStoreMap.sol";
import "./DataStoreIndexInterface.sol";
import "./DataStoreList.sol";

contract DataStoreIndex is DataStoreIndexInterface, OwnedModerated {
    uint public VERSION_ID = 1;
    DataStoreMap containers;
    uint lastModified;

    function DataStoreIndex(DataStoreMap data) {
        // --> upgrade
        containers = data;
        lastModified = now;
    }

    function containerGet(bytes32 key) constant returns (bytes32) {
        return containers.get(key);
    }

    function containerHas(bytes32 key) constant returns (bool) {
        return containers.has(key);
    }

    function containerRemove(bytes32 key) only_owner_or_moderator {
        containers.remove(key);
    }

    function containerSet(bytes32 key, bytes32 value) only_owner_or_moderator {
        containers.set(key, value);
    }

    function indexGet(bytes32 key) constant returns (DataStoreIndexInterface) {
        DataStoreIndexInterface index = DataStoreIndexInterface(address(containers.get(key)));
        return index;
    }

    function indexMakeModerator(bytes32 key) only_owner_or_moderator {
        DataStoreIndex index = DataStoreIndex(address(containers.get(key)));
        index.addModerator(msg.sender);
    }

    function listEntryAdd(bytes32 containerName, bytes32 value) only_owner_or_moderator {
        DataStoreList list = listEnsure(containerName);
        list.add(value);
        lastModified = now;
    }

    function listEntryRemove(bytes32 containerNames, uint index) only_owner_or_moderator {
        DataStoreList(getContainerAddress(containerNames)).remove(index);
        lastModified = now;
    }

    function listEntryUpdate(bytes32 containerNames, uint index, bytes32 value) only_owner_or_moderator {
        DataStoreList(getContainerAddress(containerNames)).update(index, value);
        lastModified = now;
    }

    function listEntryGet(bytes32 containerName, uint index) constant returns(bytes32) {
        return DataStoreList(getContainerAddress(containerName)).get(index);
    }

    function listIndexOf(bytes32 containerName, bytes32 value) constant returns(uint index, bool okay) {
        address listAddress = getContainerAddress(containerName);
        if (listAddress != 0x0) {
          return DataStoreList(listAddress).indexOf(value);
        }
    }

    function listLastModified(bytes32 containerName) constant returns(uint) {
        return DataStoreList(getContainerAddress(containerName)).lastModified();
    }

    function listLength(bytes32 containerName) constant returns(uint) {
        address addr = getContainerAddress(containerName);
        if (addr == 0x0) {
            return 0;
        } else {
            return DataStoreList(addr).length();
        }
    }

    function listEnsure(bytes32 containerName) private returns(DataStoreList) {
        DataStoreList list;
        address listAddress = address(containers.get(containerName));
        if (listAddress == 0x0) {
            list = new DataStoreList();
            containers.set(containerName, bytes32(address(list)));
            lastModified = now;
        } else {
            list = DataStoreList(listAddress);
        }
        return list;
    }

    function getContainerAddress(bytes32 containerName) private constant returns(address) {
        return address(containers.get(containerName));
    }

}
