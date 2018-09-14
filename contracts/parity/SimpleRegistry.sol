//! The simple registry contract.
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


// deployed at 0x3526e81615549a54494c80b8dcbef8d06c685d16
// From Registry.sol
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
contract ReverseRegistry {
  event ReverseConfirmed(string indexed name, address indexed reverse);
  event ReverseRemoved(string indexed name, address indexed reverse);

  function hasReverse(bytes32 _name) constant returns (bool);
  function getReverse(bytes32 _name) constant returns (address);
  function canReverse(address _data) constant returns (bool);
  function reverse(address _data) constant returns (string);
}

contract SimpleRegistry is Owned, MetadataRegistry, OwnerRegistry, ReverseRegistry {
  struct Entry {
    address owner;
    address reverse;
    mapping (string => bytes32) data;
  }

  event Drained(uint amount);
  event FeeChanged(uint amount);
  event ReverseProposed(string indexed name, address indexed reverse);

  // Registry functions.
  function getData(bytes32 _name, string _key) constant returns (bytes32) {
    return entries[_name].data[_key];
  }
  function getAddress(bytes32 _name, string _key) constant returns (address) {
    return address(entries[_name].data[_key]);
  }
  function getUint(bytes32 _name, string _key) constant returns (uint) {
    return uint(entries[_name].data[_key]);
  }

  // OwnerRegistry function.
  function getOwner(bytes32 _name) constant returns (address) { return entries[_name].owner; }

  // ReversibleRegistry functions.
  function hasReverse(bytes32 _name) constant returns (bool) { return entries[_name].reverse != 0; }
  function getReverse(bytes32 _name) constant returns (address) { return entries[_name].reverse; }
  function canReverse(address _data) constant returns (bool) { return bytes(reverses[_data]).length != 0; }
  function reverse(address _data) constant returns (string) { return reverses[_data]; }

  // Reservation functions.
  function reserve(bytes32 _name) when_unreserved(_name) when_fee_paid payable returns (bool success) {
    entries[_name].owner = msg.sender;
    Reserved(_name, msg.sender);
    return true;
  }

  function reserved(bytes32 _name) constant returns (bool reserved) {
    return entries[_name].owner != 0;
  }

  function transfer(bytes32 _name, address _to) only_owner_of(_name) returns (bool success) {
    entries[_name].owner = _to;
    Transferred(_name, msg.sender, _to);
    return true;
  }

  function drop(bytes32 _name) only_owner_of(_name) returns (bool success) {
    delete reverses[entries[_name].reverse];
    delete entries[_name];
    Dropped(_name, msg.sender);
    return true;
  }

  // Data admin functions.
  function setData(bytes32 _name, string _key, bytes32 _value) only_owner_of(_name) returns (bool success) {
    entries[_name].data[_key] = _value;
    DataChanged(_name, _key, _key);
    return true;
  }

  function setAddress(bytes32 _name, string _key, address _value) only_owner_of(_name) returns (bool success) {
    entries[_name].data[_key] = bytes32(_value);
    DataChanged(_name, _key, _key);
    return true;
  }

  function setUint(bytes32 _name, string _key, uint _value) only_owner_of(_name) returns (bool success) {
    entries[_name].data[_key] = bytes32(_value);
    DataChanged(_name, _key, _key);
    return true;
  }

  // Reverse registration.
  function proposeReverse(string _name, address _who) only_owner_of(keccak256(_name)) returns (bool success) {
    var keccak256Name = keccak256(_name);
    if (entries[keccak256Name].reverse != 0 && keccak256(reverses[entries[keccak256Name].reverse]) == keccak256Name) {
      delete reverses[entries[keccak256Name].reverse];
      ReverseRemoved(_name, entries[keccak256Name].reverse);
    }
    entries[keccak256Name].reverse = _who;
    ReverseProposed(_name, _who);
    return true;
  }

  function confirmReverse(string _name) when_proposed(_name) returns (bool success) {
    reverses[msg.sender] = _name;
    ReverseConfirmed(_name, msg.sender);
    return true;
  }

  function confirmReverseAs(string _name, address _who) only_owner returns (bool success) {
    reverses[_who] = _name;
    ReverseConfirmed(_name, _who);
    return true;
  }

  function removeReverse() {
    ReverseRemoved(reverses[msg.sender], msg.sender);
    delete entries[keccak256(reverses[msg.sender])].reverse;
    delete reverses[msg.sender];
  }

  // Admin functions for the owner.

  function setFee(uint _amount) only_owner returns (bool) {
    fee = _amount;
    FeeChanged(_amount);
    return true;
  }

  function drain() only_owner returns (bool) {
    Drained(this.balance);
    if (!msg.sender.send(this.balance)) throw;
    return true;
  }

  modifier when_unreserved(bytes32 _name) { if (entries[_name].owner != 0) return; _; }
  modifier only_owner_of(bytes32 _name) { if (entries[_name].owner != msg.sender) return; _; }
  modifier when_proposed(string _name) { if (entries[keccak256(_name)].reverse != msg.sender) return; _; }
  modifier when_fee_paid { if (msg.value < fee) return; _; }

  mapping (bytes32 => Entry) entries;
  mapping (address => string) reverses;

  uint public fee = 1 ether;
}
