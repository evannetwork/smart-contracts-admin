/*
  Copyright (C) 2018-present evan GmbH.

  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3,
  as published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program. If not, see http://www.gnu.org/licenses/ or
  write to the Free Software Foundation, Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA, 02110-1301 USA, or download the license from
  the following URL: https://evan.network/license/

  You can be released from the requirements of the GNU Affero General Public
  License by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts
  of it on other blockchains than evan.network.

  For more information, please contact evan GmbH at this address:
  https://evan.network/license/
*/

pragma solidity 0.4.20;


// deployed in evan.network at
contract TransactionPermissionContract {
    /// Allowed transaction types mask
    uint32 public constant NONE = 0;
    uint32 public constant ALL = 0xffffffff;
    uint32 public constant BASIC = 0x01;
    uint32 public constant CALL = 0x02;
    uint32 public constant CREATE = 0x04;
    uint32 public constant PRIVATE = 0x08;

    address public owner;
    uint32 public minimumPermission = ALL;

    mapping(address => uint32) private transactionPermissions;

    modifier onlyOwner {
        assert(owner == msg.sender);
        _;
    }

    function TransactionPermissionContract(address newOwner) public {
        owner = newOwner;
    }

    function allowedTxTypes(address sender) public returns (uint32) {
        if (sender == owner) {
            return ALL;
        } else {
            return minimumPermission | transactionPermissions[sender];
        }
    }

    function grantPermission(address sender, uint32 permission) public onlyOwner {
        transactionPermissions[sender] = transactionPermissions[sender] | permission;
    }

    function revokePermission(address sender, uint32 permission) public onlyOwner {
        transactionPermissions[sender] = transactionPermissions[sender] & (~permission);
    }

    function setPermission(address sender, uint32 permission) public onlyOwner {
        transactionPermissions[sender] = permission;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function setMinimumPermission(uint32 newMinimumPermission) public onlyOwner {
        minimumPermission = newMinimumPermission;
    }
}
