//! The registry contract.
//!
//! Copyright 2016 Gavin Wood, Parity Technologies Ltd.
//!
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//!
//!     http://www.apache.org/licenses/LICENSE-2.0
//!
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.

pragma solidity ^0.4.0;

import "./Owned.sol";

contract MetadataRegistry {
  event DataChanged(bytes32 indexed name, string indexed key, string plainKey);

  function getData(bytes32 _name, string _key) constant returns (bytes32);
  function getAddress(bytes32 _name, string _key) constant returns (address);
  function getUint(bytes32 _name, string _key) constant returns (uint);
}

contract OwnerRegistry {
  event Reserved(bytes32 indexed name, address indexed owner);
  event Transferred(bytes32 indexed name, address indexed oldOwner, address indexed newOwner);
  event Dropped(bytes32 indexed name, address indexed owner);

  function getOwner(bytes32 _name) constant returns (address);
}

contract ReversibleRegistry {
  event ReverseConfirmed(string indexed name, address indexed reverse);
  event ReverseRemoved(string indexed name, address indexed reverse);

  function hasReverse(bytes32 _name) constant returns (bool);
  function getReverse(bytes32 _name) constant returns (address);
  function canReverse(address _data) constant returns (bool);
  function reverse(address _data) constant returns (string);
}
