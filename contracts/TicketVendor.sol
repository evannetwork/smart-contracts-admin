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
*/

pragma solidity ^0.4.20;

import "./ds-auth/auth.sol";
import "./oraclizeAPI_0.4.sol";
import "./strings.sol";
import "./TicketVendorInterface.sol";


contract TicketVendor is usingOraclize, DSAuth, TicketVendorInterface {
    using strings for *;

    uint256 public gasLimit = 175000;
    uint256 public queryRepeat = 55 minutes;
    uint256 private ticketCount;
    mapping(uint256 => uint256) private ticketIssued;
    mapping(uint256 => address) private ticketOwner;
    mapping(uint256 => uint256) private ticketPrice;
    mapping(uint256 => uint256) private ticketValue;
    uint256 private priceEveWeiPerEther = 0;
    uint256 private priceLastUpdated = 0;
    uint256 private priceMaxAge = 1 hours;
    string private query = "json(https://api.gdax.com/products/ETH-EUR/TICKER).price";
    mapping(bytes32=>bool) private validIds;

    // accept funds for using it in oraclize restests later
    function () public payable {
        // accept funds
    }

    constructor() public {
        oraclize_setCustomGasPrice(5000000000);
    }

    /// @notice callback for oraclize queries
    /// @dev https://docs.oraclize.it
    /// @param result query result, new price
    function __callback(bytes32 queryId, string result) public {
        if (!validIds[queryId]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        priceEveWeiPerEther = convertToWei(result);
        priceLastUpdated = now;
        delete validIds[queryId];
        if (queryRepeat > 0) {
            assert(oraclize_getPrice("URL") <= this.balance);
            bytes32 newQuery = oraclize_query(queryRepeat, "URL", query, gasLimit);
            validIds[newQuery] = true;
        }
    }

    // sends funds to caller
    /// @dev callable by owner
    function claimFunds() public auth {
        msg.sender.transfer(this.balance);
    }

    /// @notice creates new ticket
    /// @dev callable by anyone
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    function requestTicket(uint256 value) public {
        uint256 ticketId = ticketCount++;
        var (price, , okay) = getCurrentPrice();
        assert(okay);

        ticketIssued[ticketId] = now;
        ticketOwner[ticketId] = msg.sender;
        ticketPrice[ticketId] = price;
        ticketValue[ticketId] = value;

        TicketCreated(msg.sender, ticketId);
    }

    /// @notice creates new owner ticket; owner tickets are issued with the given price
    /// @dev callable by owner
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    /// @param price ticket will be issued with this price 
    function requestOwnerTicket(uint256 value, uint256 price) public auth {
        uint256 ticketId = ticketCount++;

        ticketIssued[ticketId] = now;
        ticketOwner[ticketId] = msg.sender;
        ticketPrice[ticketId] = price;
        ticketValue[ticketId] = value;

        TicketCreated(msg.sender, ticketId);
    }

    // set new limit for oraclize requests
    /// @dev callable by owner
    /// @param _gasLimit new limit
    function setGasLimit(uint256 _gasLimit) public auth {
        gasLimit = _gasLimit;
    }

    // set new gas price for oraclize requests
    /// @dev callable by owner
    /// @param _gasPrice new price
    function setGasPrice(uint256 _gasPrice) public auth {
        oraclize_setCustomGasPrice(_gasPrice);
    }

    // set repetition for query, 0 disables repetition
    /// @dev callable by owner
    /// @param _queryRepeat delay for queries
    function setQueryRepeat(uint256 _queryRepeat) public auth {
        queryRepeat = _queryRepeat;
    }

    // update maximum age of price
    /// @notice tickets cannot be issued if this age is exceeded
    /// @dev callable by owner
    /// @param newPriceMaxAge new max age for price
    function setPriceMaxAge(uint256 newPriceMaxAge) public auth {
        priceMaxAge = newPriceMaxAge;
    }

    /// @notice set query used when updating prices
    /// @param newQuery updated query
    function setQuery(string newQuery) public auth {
        query = newQuery;
    }

    /// @notice call oracle for pricing update
    /// @dev callable by owner / manager (tbd)
    function updatePrice() public payable auth {
        assert(oraclize_getPrice("URL") <= this.balance);
        bytes32 queryId = oraclize_query("URL", query, gasLimit);
        validIds[queryId] = true;
    }

    /// @notice get get current price and last update (as seconds since unix epoch)
    /// @return eveWeiPerEther current transfer rate (EVE (even.network) per ETHER (Ethereum public chain))
    /// @return price, lastUpdated and info if price is valid
    function getCurrentPrice() public view returns(
        uint256 eveWeiPerEther, uint256 lastUpdated, bool okay) {
        if ((priceEveWeiPerEther != 0 && priceLastUpdated != 0) &&
            (priceLastUpdated >= now - getPriceMaxAge())) {
            okay = true;
        }
        return (priceEveWeiPerEther, priceLastUpdated, okay);
    }

    /// @notice get current number of tickets
    /// @return current number of tickets
    function getTicketCount() public view returns (uint256) {
        return ticketCount;
    }

    /// @notice get max age that the price can have when issuing a ticket
    /// @return priceMaxAge max age for price
    function getPriceMaxAge() public view returns(uint256) {
        return priceMaxAge;
    }

    /// @notice get query used when updating prices
    /// @return oraclize URL query string
    function getQuery() public view returns(string) {
        return query;
    }

    /// @notice get ticket info
    /// @param ticketId id of the ticket to look up
    /// @return owner ticket owner
    /// @return price price, that has been locked for ticket
    /// @return issued expiration date for ticket
    /// @return value transfer value
    function getTicketInfo(uint256 ticketId) public view returns(
            address owner, uint256 price, uint256 issued, uint256 value) {
        issued = ticketIssued[ticketId];
        owner = ticketOwner[ticketId];
        price = ticketPrice[ticketId];
        value = ticketValue[ticketId];
    }

    /// @notice check costs for updating price at oraclize
    /// @return cost for a price update
    function getUpdatePriceCost() public view returns (uint256 cost) {
        return oraclize_getPrice("URL");
    }

    /// @notice convert string value in ETHER/EVE with decimals to Wei uint
    /// @param floatString string to convert
    /// @return Wei value
    function convertToWei(string floatString) private view returns(uint256) {
        var fractional = floatString.toSlice();
        var integer = fractional.split(".".toSlice());
        uint fractionalLength = fractional.len();
        assert(fractionalLength <= 18);
        if (fractionalLength < 18) {
            var zero = "0".toSlice();
            for (uint i = 0; i + fractionalLength < 18; i++) {
                fractional = fractional.concat(zero).toSlice();
            }
        }
        return (parseInt(integer.concat(fractional)));
    }
}
