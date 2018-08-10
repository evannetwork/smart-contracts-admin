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

import "./Core.sol";

contract DataStoreList is Owned {
    uint public length;
    uint public lastModified;
    mapping(uint => bytes32) data;

    function add(bytes32 value) only_owner {
        uint index = length++;
        data[index] = value;
        lastModified = now;
    }

    function remove(uint index) only_owner {
        var lastIndex = --length;
        if (lastIndex != 0) {
            data[index] = data[lastIndex];
        }
        delete data[lastIndex];
        lastModified = now;
    }

    function update(uint index, bytes32 value) only_owner {
        assert(index <= length);
        data[index] = value;
        lastModified = now;
    }

    function get(uint index) constant returns(bytes32) {
        return data[index];
    }

    function indexOf(bytes32 value) constant returns(uint index, bool okay) {
        okay = false;
        for (uint256 i = 0; i < length; i++) {
            if (data[i] == value) {
                index = i;
                okay = true;
                break;
            }
        }
    }

}
