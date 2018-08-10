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


/// @title triggering data contract events
/// @author contractus GmbH
/// @notice used as a base class for EventHub
contract EventHubDataContract {

    event DataContractEvent(
        address indexed sender,
        bytes32 indexed propertyType,
        bytes32[] indexed propertyKeys,
        bytes32 updateType,
        uint256 updated
    );

    /// @notice send data contract from this event hub
    /// @param propertyType type of property that was updated (entry / list entry)
    /// @param propertyKeys name of property that was updated
    /// @param updateType type update (set / remove)
    /// @param updated number of updated elments in addListEntry, index of removed entry in removeListEntry
    function sendDataContractEvent(bytes32 propertyType, bytes32[] propertyKeys, bytes32 updateType, uint256 updated) public {
        DataContractEvent(msg.sender, propertyType, propertyKeys, updateType, updated);
    }
}
