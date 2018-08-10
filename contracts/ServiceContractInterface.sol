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

import "./BaseContractInterface.sol";

contract ServiceContractInterface is BaseContractInterface {
    bytes32 public service;
    // total count of all threads
    uint256 public callCount;
    // all calls
    mapping(uint256 => bytes32) public calls;
    // [7] == 3 --> call 7 has 3 answers
    mapping(uint256 => uint256) public answersCountPerCall;
    // [7[1] == 0x123 --> second answer to mail 7 is 0x123
    mapping(uint256 => mapping(uint256 => bytes32)) public answersPerCall;

    function setService(address _businessCenter, bytes32 hash) public;
    function sendAnswer(bytes32 answerHash, uint256 callId) public;
    function sendCall(bytes32 callHash) public;
}
