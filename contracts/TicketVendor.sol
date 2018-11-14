pragma solidity ^0.4.20;

import "./ds-auth/auth.sol";
import "./oraclizeAPI_0.4.sol";
import "./strings.sol";
import "./TicketVendorInterface.sol";


contract TicketVendor is usingOraclize, DSAuth, TicketVendorInterface {
    // TODO: upgradeability --> move storage into UpgradeabilityProxy.sol
    // https://github.com/poanetwork/poa-bridge-contracts/blob/master/contracts/upgradeability/UpgradeabilityProxy.sol
    // GPL-3.0 (but check file headers again)
    using strings for *;

    uint256 private ticketCount;
    mapping(uint256 => uint256) private ticketIssued;
    mapping(uint256 => address) private ticketOwner;
    mapping(uint256 => uint256) private ticketPrice;
    mapping(uint256 => uint256) private ticketValue;
    uint256 private priceEveWeiPerEther = 0;
    uint256 private priceLastUpdated = 0;
    uint256 private priceMaxAge = 1 hours;
    string private query = "json(https://api.gdax.com/products/ETH-EUR/TICKER).price";

    /// @notice callback for oraclize queries
    /// @dev https://docs.oraclize.it
    /// @param result query result, new price
    function __callback(bytes32, string result) public {
        assert(msg.sender == oraclize_cbAddress());
        priceEveWeiPerEther = convertToWei(result);
        priceLastUpdated = now;
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
        assert(oraclize_getPrice("URL") > this.balance);
        oraclize_query("URL", query);
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
