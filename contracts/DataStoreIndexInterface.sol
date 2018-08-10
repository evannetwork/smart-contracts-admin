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


interface DataStoreIndexInterface {
    function containerGet(bytes32 key) public constant returns (bytes32);

    function containerHas(bytes32 key) public constant returns (bool);

    function containerRemove(bytes32 key) public;

    function containerSet(bytes32 key, bytes32 value) public;

    function indexGet(bytes32 key) public constant returns (DataStoreIndexInterface);

    function indexMakeModerator(bytes32 key) public;

    function listEntryAdd(bytes32 containerName, bytes32 value) public;

    function listEntryRemove(bytes32 containerNames, uint index) public;

    function listEntryUpdate(bytes32 containerNames, uint index, bytes32 value) public;

    function listEntryGet(bytes32 containerName, uint index) public constant returns(bytes32);

    function listIndexOf(bytes32 containerName, bytes32 value) public constant returns(uint index, bool okay);

    function listLastModified(bytes32 containerName) public constant returns(uint);

    function listLength(bytes32 containerName) public constant returns(uint);
}
