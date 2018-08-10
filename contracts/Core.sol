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

// empty contract for keeping filename -> contract name behavior
contract Core {}

contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) only_owner {
        owner = newOwner;
    }

    // This only allows the owner to perform function
    modifier only_owner {
      assert(msg.sender == owner);
      _;
    }
}

contract OwnedMortal is Owned {
    function kill() only_owner {
        suicide(owner);
    }
}

contract OwnedModerated is Owned {
    mapping(address => bool) public moderators;

    function addModerator(address newModerator) only_owner {
        moderators[newModerator] = true;
    }

    function removeModerator(address newModerator) only_owner {
        delete moderators[newModerator];
    }

    function removeModeratorship() only_owner_or_moderator {
        delete moderators[msg.sender];
    }

    function transferModeratorship(address newModerator) only_owner_or_moderator {
        delete moderators[msg.sender];
        moderators[newModerator] = true;
    }

    // This only allows moderator to perform function
    modifier only_owner_or_moderator {
      assert(msg.sender == owner || moderators[msg.sender]);
      _;
    }
}
