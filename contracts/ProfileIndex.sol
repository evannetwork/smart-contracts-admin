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

pragma solidity ~0.4.24;

import "./Core.sol";
import "./EnsReader.sol";
import "./DataStoreIndexInterface.sol";
import "./ProfileIndexInterface.sol";


/** @title Profile Index Contract - stores all personal profile containers */
contract ProfileIndex is ProfileIndexInterface, Owned, EnsReader {
    bytes32 private constant EVENTHUB_LABEL =
        0xea14ea6d138254c1a2931c6a19f6888c7b52f512d165cfa428183a53dd9dfb8c; //web3.keccak256('eventhub')

    bytes32 private constant PROFILE_LABEL =
        0xe3dd854eb9d23c94680b3ec632b9072842365d9a702ab0df7da8bc398ee52c7d; //web3.keccak256('profile')

    DataStoreIndexInterface private db;

    /**@dev Creates new RessourceContract.
     * @param database previously created index
     */
    function ProfileIndex(DataStoreIndexInterface database) public {
        db = database;
    }

    /**@dev tries to get the ipld hash for a given label
     * @param account accountid for profile
     * @return hash of the label
     */
    function getProfile(address account) public constant returns (address) {
        bytes32 keyForIndex = keccak256(PROFILE_LABEL, keccak256(bytes32(account)));
        return address(db.containerGet(keyForIndex));
    }

    /**@dev transfers ownership of storage to another contract
     * @param newProfileIndex new profile index to hand over storage to
     */
    function migrateTo(address newProfileIndex) public only_owner {
        Owned(db).transferOwnership(newProfileIndex);
    }

    /**@dev sets own profile
     * @param _address contract address that holds the information.
     */
    function setMyProfile(address _address) public {
        bytes32 keyForIndex = keccak256(PROFILE_LABEL, keccak256(bytes32(msg.sender)));
        db.containerSet(keyForIndex, bytes32(_address));
    }

    /**@dev sets a profile for a given account
     * @param account account to set profile for
     * @param profile contract address that holds the information.
     */
    function setProfile(address account, address profile) public only_owner {
        bytes32 keyForIndex = keccak256(PROFILE_LABEL, keccak256(bytes32(account)));
        db.containerSet(keyForIndex, bytes32(profile));
    }

    /**@dev returns the global db for migration purposes
     * @return global db
     */    
    function getStorage() public constant returns (DataStoreIndexInterface) {
        return db;
    }
}
