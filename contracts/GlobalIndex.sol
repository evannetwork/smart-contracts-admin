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
import "./DataStoreIndex.sol";

contract GlobalIndex is Owned {
    bytes32 constant memberLabel = 0x14ceb1149cdab84b395151a21d3de6707dd76fff3e7bc4e018925a9986b7f72f; //web3.sha3('member')
    DataStoreIndex public db;

    function GlobalIndex(DataStoreIndex database) {
        db = database;
    }

    function getMyIndex() constant returns (DataStoreIndex) {
      bytes32 keyForMemberIndex = sha3(memberLabel, sha3(bytes32(msg.sender)));
      return DataStoreIndex(db.indexGet(keyForMemberIndex));
    }

    function getStorage() only_owner constant returns (DataStoreIndex) {
      return db;
    }
}
