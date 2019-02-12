pragma solidity ^0.4.24;

import "./ds-auth/auth.sol";

contract BlockRewardContract is DSAuth {

    bytes32 internal constant EXTRA_RECEIVERS = keccak256("extraReceivers");
    bytes32 internal constant MINTED_TOTALLY = keccak256("mintedTotally");

    bytes32 internal constant EXTRA_RECEIVERS_AMOUNTS = "extraReceiversAmounts";
    bytes32 internal constant MINTED_FOR_ACCOUNT = "mintedForAccount";
    bytes32 internal constant MINTED_FOR_ACCOUNT_IN_BLOCK = "mintedForAccountInBlock";
    bytes32 internal constant MINTED_IN_BLOCK = "mintedInBlock";

    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => uint256) internal uintStorage;

    event AddedReceiver(uint256 amount, address indexed receiver);
    event Rewarded(address[] receivers, uint256[] rewards);
    
    constructor(address newOwner) public DSAuth() {
        setOwner(newOwner);
    }

    modifier onlySystem {
        require(msg.sender == 0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE);
        _;
    }

    function addExtraReceiver(uint256 _amount, address _receiver)
        external
        auth
    {
        require(_amount != 0);
        require(_receiver != address(0));
        uint256 oldAmount = extraReceiversAmounts(_receiver);
        if (oldAmount == 0) {
            _addExtraReceiver(_receiver);
        }
        _setExtraReceiverAmount(oldAmount + _amount, _receiver);
        emit AddedReceiver(_amount, _receiver);
    }

    function reward(address[] benefactors, uint16[] kind)
        external
        onlySystem
        returns (address[], uint256[])
    {
        require(benefactors.length == kind.length);
        require(benefactors.length == 1);
        require(kind[0] == 0);

        uint256 extraLength = extraReceiversLength();

        address[] memory receivers = new address[](extraLength);
        uint256[] memory rewards = new uint256[](extraLength);

        uint256 i;
        
        for (i = 0; i < extraLength; i++) {
            uint256 extraIndex = i;
            address extraAddress = extraReceivers(i);
            uint256 extraAmount = extraReceiversAmounts(extraAddress);
            _setExtraReceiverAmount(0, extraAddress);
            receivers[extraIndex] = extraAddress;
            rewards[extraIndex] = extraAmount;
        }

        for (i = 0; i < receivers.length; i++) {
            _setMinted(rewards[i], receivers[i]);
        }

        _clearExtraReceivers();

        emit Rewarded(receivers, rewards);
    
        return (receivers, rewards);
    }

    function extraReceivers(uint256 _index) public view returns(address) {
        return addressArrayStorage[EXTRA_RECEIVERS][_index];
    }

    function extraReceiversAmounts(address _receiver) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(EXTRA_RECEIVERS_AMOUNTS, _receiver))
        ];
    }

    function extraReceiversLength() public view returns(uint256) {
        return addressArrayStorage[EXTRA_RECEIVERS].length;
    }

    function mintedForAccount(address _account)
        public
        view
        returns(uint256)
    {
        return uintStorage[
            keccak256(abi.encode(MINTED_FOR_ACCOUNT, _account))
        ];
    }

    function mintedForAccountInBlock(address _account, uint256 _blockNumber)
        public
        view
        returns(uint256)
    {
        return uintStorage[
            keccak256(abi.encode(MINTED_FOR_ACCOUNT_IN_BLOCK, _account, _blockNumber))
        ];
    }

    function mintedInBlock(uint256 _blockNumber) public view returns(uint256) {
        return uintStorage[
            keccak256(abi.encode(MINTED_IN_BLOCK, _blockNumber))
        ];
    }

    function mintedTotally() public view returns(uint256) {
        return uintStorage[MINTED_TOTALLY];
    }

    function _addExtraReceiver(address _receiver) private {
        addressArrayStorage[EXTRA_RECEIVERS].push(_receiver);
    }

    function _clearExtraReceivers() private {
        addressArrayStorage[EXTRA_RECEIVERS].length = 0;
    }

    function _setExtraReceiverAmount(uint256 _amount, address _receiver) private {
        uintStorage[
            keccak256(abi.encode(EXTRA_RECEIVERS_AMOUNTS, _receiver))
        ] = _amount;
    }

    function _setMinted(uint256 _amount, address _account) private {
        bytes32 hash;

        hash = keccak256(abi.encode(MINTED_FOR_ACCOUNT_IN_BLOCK, _account, block.number));
        uintStorage[hash] = _amount;

        hash = keccak256(abi.encode(MINTED_FOR_ACCOUNT, _account));
        uintStorage[hash] = uintStorage[hash] + _amount;

        hash = keccak256(abi.encode(MINTED_IN_BLOCK, block.number));
        uintStorage[hash] = uintStorage[hash] + _amount;

        hash = MINTED_TOTALLY;
        uintStorage[hash] = uintStorage[hash] + _amount;
    }
}