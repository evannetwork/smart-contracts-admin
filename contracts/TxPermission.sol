/*
  license header omitted, as code is based on
    https://gist.github.com/VladLupashevskyi/84f18eabb1e4afadf572cf92af3e7e7f
    and
    https://github.com/paritytech/parity-ethereum/pull/8400
*/

pragma solidity ^0.4.20;

import "./DataStoreMap.sol";


/**
 * @dev        updated permission contract for transaction permissions,
 *             code is based on https://gist.github.com/VladLupashevskyi/84f18eabb1e4afadf572cf92af3e7e7f
 *             gist is related to issue "Tx permission contract improvement #8400"
 *               (https://github.com/paritytech/parity-ethereum/pull/8400)
 *             has to be configured in chain spec json, '/params/': ,
 *                 "transactionPermissionContract": "0xce24af4422c7d7e4aade1dd6594b4c4fc7e8bd58",
 *                 "transactionPermissionContractTransition": "1",
 */
contract TxPermission {
    /// Allowed transaction types mask
    uint32 public constant None = 0;
    uint32 public constant All = 0xffffffff;
    uint32 public constant Basic = 0x01;
    uint32 public constant Call = 0x02;
    uint32 public constant Create = 0x04;
    uint32 public constant Private = 0x08;

    address public owner;
    uint32 public minimumPermission = All;
    DataStoreMap public data;

    // keccak256("senderPermissions")
    bytes32 private constant SENDER_PERMISSIONS_LABEL =
        0xfec09efc8494b5113a8060ffd199d56995a235a731b54bda5f92286be0ad9370;

    // keccak256("targetProhibitions")
    bytes32 private constant TARGET_PROHIBITIONS_LABEL =
        0xc6192c1533074024f0f6acf7d0333d42fe3836be0e1f1839a0ec816ecdd2b737;

    modifier onlyOwner {
        assert(owner == msg.sender);
        _;
    }

    /**
     * @dev        creates new TxPermission contract
     * @param      newOwner  owner of the contract, permission check for owner always returns "All"
     * @param      _data     DataStoreMap contract, used for storing permissions and prohibitions
     */
    function TxPermission(address newOwner, DataStoreMap _data) public {
        owner = newOwner;
        if (_data != address(0)) {
            data = _data;
        }
    }

    /**
     * @dev        add permission to a senders permission set, only adds, doesn't touch omitted bits
     * @param      sender      account id
     * @param      permission  uint32 permission value
     */
    function grantPermission(address sender, uint32 permission) public onlyOwner {
        bytes32 label = keccak256(SENDER_PERMISSIONS_LABEL, sender);
        uint32 oldValue = uint32(data.get(label));
        data.set(label, bytes32(oldValue | permission));
    }

    /**
     * @dev        add prohibition to a targets prohibition set, only adds, doesn't touch omitted
     *             bits
     * @param      to          account id
     * @param      permission  uint32 permision value
     */
    function grantProhibition(address to, uint32 permission) public onlyOwner {
        bytes32 label = keccak256(TARGET_PROHIBITIONS_LABEL, to);
        uint32 oldValue = uint32(data.get(label));
        data.set(label, bytes32(oldValue | permission));
    }

    /**
     * @dev        transfer data ownership to another account, when migrating data to next contract
     * @param      newContract  address of a new (TxPermission) contract
     */
    function migrateTo(address newContract) public onlyOwner {
        data.transferOwnership(newContract);
    }

    /**
     * @dev        revoke a permission from a senders permission set, only revokes, doesn't touch
     *             omitted bits
     * @param      sender      account id
     * @param      permission  uint32 permission value
     */
    function revokePermission(address sender, uint32 permission) public onlyOwner {
        bytes32 label = keccak256(SENDER_PERMISSIONS_LABEL, sender);
        uint32 oldValue = uint32(data.get(label));
        data.set(label, bytes32(oldValue & (~permission)));
    }

    /**
     * @dev        revoke a permission from a targets prohibition set, only revokes, doesn't touch
     *             omitted bits
     * @param      to          account id
     * @param      permission  uint32 permision value
     */
    function revokeProhibition(address to, uint32 permission) public onlyOwner {
        bytes32 label = keccak256(TARGET_PROHIBITIONS_LABEL, to);
        uint32 oldValue = uint32(data.get(label));
        data.set(label, bytes32(oldValue & (~permission)));
    }

    /**
     * @dev        set a senders permission set, this replaces the permission value entirely
     * @param      sender      account id
     * @param      permission  uint32 permission value
     */
    function setPermission(address sender, uint32 permission) public onlyOwner {
        data.set(keccak256(SENDER_PERMISSIONS_LABEL, sender), bytes32(permission));
    }

    /**
     * @dev        set a targets prohibition set, this replaces the prohibition value entirely
     * @param      to          account id
     * @param      permission  uint32 permision value
     */
    function setProhibition(address to, uint32 permission) public onlyOwner {
        data.set(keccak256(TARGET_PROHIBITIONS_LABEL, to), bytes32(permission));
    }
    
    /**
     * @dev        set minimum permission, this is added to all senders permission checks, when
     *             evaluating. prohibitions are still able to cancel out sender and minimum
     *             permissions, as prohibitions are applied after user and minimum permissions
     * @param      newMinimumPermission  uint32 permission value
     */
    function setMinimumPermission(uint32 newMinimumPermission) public onlyOwner {
        minimumPermission = newMinimumPermission;
    }

    /**
     * @dev        transfer ownership of TxPermission contract to another account
     * @param      newOwner  next owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    /**
     * @dev        Contract name
     */
    function contractName() public pure returns (string) {
        return "TX_PERMISSION_CONTRACT";
    }
    
    /**
     * @dev        Contract name hash
     */
    function contractNameHash() public pure returns (bytes32) {
        return keccak256(contractName());
    }
    
    /**
     * @dev        Contract version
     */
    function contractVersion() public pure returns (uint256) {
        return 2;
    }

    /*
     * Allowed transaction types
     * 
     * Returns:
     *  - uint32 - set of allowed transactions for #'sender' depending on tx #'to' address
     *    and value in wei.
     *  - bool - if true is returned the same permissions will be applied from the same #'sender' 
     *    without calling this contract again.
     *
     * In case of contract creation #'to' address equals to zero-address
     * 
     * Result is represented as set of flags:
     *  - 0x01 - basic transaction (e.g. ether transferring to user wallet)
     *  - 0x02 - contract call
     *  - 0x04 - contract creation
     *  - 0x08 - private transaction
     *
     * @param sender Transaction sender address
     * @param to Transaction recepient address
     * @param value Value in wei for transaction
     * 
     */
    function allowedTxTypes(address sender, address to, uint /* value */) public view returns (uint32, bool) {
        if (sender == owner) {
            return (All, false);
        } else {
            uint32 senderPermissions = uint32(
                data.get(keccak256(SENDER_PERMISSIONS_LABEL, sender)));
            uint32 targetProhibitions = uint32(
                data.get(keccak256(TARGET_PROHIBITIONS_LABEL, to)));
            return (((senderPermissions | minimumPermission) & (targetProhibitions ^ All)), false);
        }
    }
}