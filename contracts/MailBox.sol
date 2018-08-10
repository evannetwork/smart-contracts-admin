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
import "./EnsReader.sol";
import "./DataStoreIndex.sol";
import "./EventHubMailBox.sol";
import "./ProfileIndex.sol";
import "./DataContractInterface.sol";


/** @title MailBox Contract - stores messages and replies */
contract MailBox is Owned, EnsReader {

    //web3.sha3('addressbooks') 0xab2cd606d9bab2fcf61e4cdadd695a76752cda02740e85d1ae4046c311f1c192; 
    bytes32 constant MAILS_LABEL = 0x6131329eed5a23aee1d464e8f88d6490e3ef07a83f8709a0f18adf40db7fc64c; //web3.sha3('mails')
    bytes32 constant EVENTHUB_LABEL = 0xea14ea6d138254c1a2931c6a19f6888c7b52f512d165cfa428183a53dd9dfb8c; //web3.sha3('eventhub')
    bytes32 constant MAIL2ANSWER_LABEL = 0x6a6b1ee2270de8bc4d3aa3db514533fdedccfeb8a850de7ecb25c99caf12c766; //web3.sha3('mail2Answer')
    bytes32 constant USER2MAIL_LABEL = 0x6fdfea841b8db1105287ab63ddddf7e4d93f49be0650b1de06832884ae1ca2b5; //web3.sha3('user2Mail')
    bytes32 constant USER2MAILSENT_LABEL = 0xdc52fa714e35ab8c7a0294d979ea831031c8168677cf3e99ef737c1846271ec7; //web3.sha3('user2MailSent')
    bytes32 constant MAILSENT2USER_LABEL = 0x5696130b5d482639e87bb0271bbd5611cc154617cfadf9b55c646d1e5af2e854; //web3.sha3('mailSent2User')
    bytes32 constant MAIL2ACCOUNT2BALANCE_LABEL = 0xf25aad3290e12dc6011a6c9ae45640eec0930ed21058f0595474cad21e91b7d7; //web3.sha3('mail2Account2Balance')
    bytes32 constant PROFILE_INDEX_LABEL = 0xe3dd854eb9d23c94680b3ec632b9072842365d9a702ab0df7da8bc398ee52c7d; //web3.sha3('profile')
    bytes32 constant CONTACTS_LABEL = 0x8417ef2e3e7bb6630d90a4cdcc188db4bcc27d6b2d8891b376ef771499bb4299; //web3.sha3('contacts')
    DataStoreIndex public db;
    uint256 mailCount = 0;


    /**@dev Creates new MailBox.
     * @param database previously created index
     */
    function MailBox(DataStoreIndex database) {
        db = database;
    }

    /**@dev returns the mailbox from the sender
     * @return address of the datastorelist
     */
    function getMyReceivedMails() public constant returns (bytes32) {
        return db.containerGet(sha3(USER2MAIL_LABEL, sha3(bytes32(msg.sender))));
    }


    /**@dev returns the mailbox from the sender
     * @return address of the datastorelist
     */
    function getMySentMails() public constant returns (bytes32) {
        return db.containerGet(sha3(USER2MAILSENT_LABEL, sha3(bytes32(msg.sender))));
    }

    /**@dev returns a specific mail 
     *
     * @param mailId id of the target mail
     * @return hash of the mail content and the mail sender
     */
    function getMail(uint256 mailId) public constant returns (bytes32 data, bytes32 sender) {
        data = db.containerGet(sha3(MAILS_LABEL, mailId));
        sender = db.containerGet(sha3(MAILSENT2USER_LABEL, bytes32(mailId)));
    }

    /**@dev returns all answers for a specific mail
     *
     * @param mailId id of the target mail
     * @return address of the datastorelist with all answers
     */
    function getAnswersForMail(uint256 mailId) public constant returns (bytes32) {
        return db.containerGet(sha3(MAIL2ANSWER_LABEL, mailId));
    }

    /**@dev sends a mail to given users
     *
     * @param recipients array of recipient addresses
     * @param mailHash hash of the mail content
     */
    function sendMail(address[] recipients, bytes32 mailHash) public payable {
        send(recipients, mailHash, false, 0);
    }

    /**@dev sends an anwser to given users
     *
     * @param recipients array of recipient addresses
     * @param mailHash hash of the mail content
     */
    function sendAnswer(address[] recipients, bytes32 mailHash, uint256 mailId) public payable {
        send(recipients, mailHash, true, mailId);
    }

    /**@dev helper for sending mails/answers to given addresses
     *
     * @param recipients array of recipient addresses
     * @param mailHash hash of the mail content
     * @param answer type of the message, true if message is a answer
     * @param mailAnswerId id reference to the original mail id
     */
    function send(address[] recipients, bytes32 mailHash, bool answer, uint256 mailAnswerId) private {
        assert (msg.value % recipients.length == 0);
        uint256 perRecipient = msg.value / recipients.length;
        uint256 mailId = mailCount++;

        // store mail
        db.containerSet(sha3(MAILS_LABEL, mailId), mailHash);   

        // keep mail for msg.senders 'outbox'
        db.listEntryAdd(sha3(USER2MAILSENT_LABEL, sha3(bytes32(msg.sender))), bytes32(mailId));

        // store msg.sender as the sender of this mail
        db.containerSet(sha3(MAILSENT2USER_LABEL, bytes32(mailId)), sha3(msg.sender));

        if (answer) {
            // assign mail as an answer
            db.listEntryAdd(sha3(MAIL2ANSWER_LABEL, mailAnswerId), bytes32(mailId));
        }

        ProfileIndex pIndex = ProfileIndex(getAddr(PROFILE_INDEX_LABEL));
        EventHubMailBox mailBoxEventHub = EventHubMailBox(getAddr(EVENTHUB_LABEL));
        for (uint i = 0; i < recipients.length; ++i) {
            // get recipients known accounts, check if sender has its known flag set in there (last bit is true)
            DataContractInterface profile = DataContractInterface(pIndex.getProfile(recipients[i]));
            assert((profile.getMappingValue(CONTACTS_LABEL, sha3(msg.sender)) & 1) == 1);
            if (msg.value != 0) {
                bytes32 key = sha3(MAIL2ACCOUNT2BALANCE_LABEL, bytes32(mailId), bytes32(recipients[i]));
                uint256 balance = (uint256)(db.containerGet(key));
                db.containerSet(key, (bytes32)(balance + perRecipient));
            }
            db.listEntryAdd(sha3(USER2MAIL_LABEL, sha3(bytes32(recipients[i]))), bytes32(mailId));
            mailBoxEventHub.sendMailEvent(recipients[i], mailId);
        }
    }

    function withdrawFromMail(uint256 mailId, address recipient) public {
        // prevent sending EVEs to 0x0
        assert(recipient != address(0));
        bytes32 key = sha3(MAIL2ACCOUNT2BALANCE_LABEL, bytes32(mailId), bytes32(msg.sender));
        uint256 balance = (uint256)(db.containerGet(key));
        db.containerSet(key, 0);
        recipient.transfer(balance);
    }

    function getBalanceFromMail(uint256 mailId) public constant returns(uint256) {
        bytes32 key = sha3(MAIL2ACCOUNT2BALANCE_LABEL, bytes32(mailId), bytes32(msg.sender));
        return (uint256)(db.containerGet(key));
    }

    /**@dev returns the global db for migration purposes
     * @return global db
     */    
    function getStorage() constant returns (DataStoreIndex) {
        return db;
    }

}
