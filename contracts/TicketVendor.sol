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

    // TODO: make ticket info private
    uint256 public ticketCount;
    mapping(uint256 => address) public ticketOwner;
    mapping(uint256 => uint256) public ticketPrice;
    mapping(uint256 => uint256) public ticketValidUntil;
    mapping(uint256 => uint256) public ticketValue;
    uint256 private currentPrice;
    uint256 private defaultUptime = 15 minutes;
    uint256 private priceEveWeiPerEther;
    uint256 private priceLastUpdated;
    uint256 private minValue = 1 ether;

    /// @notice callback for oraclize queries
    /// @dev https://docs.oraclize.it
    /// @param result query result, new price
    function __callback(bytes32, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        // parsing is gonna be fund...
        // --> type missmatch, etc, I know, this's for demo only
        priceEveWeiPerEther = convertToWei(result);
    }

    /// @notice invalidates ticket (delete or invalidate? (tbd))
    /// @dev callable by home bridge (tbd),
    /// emits TicketConsumed
    /// @param ticketId id of the ticket to consume
    function consumeTicket(uint256 ticketId) public auth {
        delete ticketOwner[ticketId];
        delete ticketPrice[ticketId];
        delete ticketValidUntil[ticketId];
        delete ticketValue[ticketId];
    }

    /// @notice creates new ticket
    /// @dev callable by anyone
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    function requestTicket(uint256 value) public {
        assert(value >= getTicketMinValue());
        uint256 ticketId = ticketCount++;
        var (price, ) = getCurrentPrice();

        ticketOwner[ticketId] = msg.sender;
        ticketPrice[ticketId] = price;
        ticketValidUntil[ticketId] = now + getDefaultTicketUptime();
        ticketValue[ticketId] = value;

        TicketCreated(msg.sender, ticketId);
    }

    /// @notice set default uptime
    /// @dev callable by owner
    /// @param newDefaultUptime new value for updtime (as seconds since unix epoch)
    function setDefaultTicketUptime(uint256 newDefaultUptime) public auth {
        defaultUptime = newDefaultUptime;
    }

    // update minimum transfer value (home network, payed in Wei)
    /// @notice creates new ticket
    /// @dev callable by owner
    /// @param newMinValue new minimum transfer value
    function setMinValue(uint256 newMinValue) public auth {
        minValue = newMinValue;
    }

    /// @notice call oracle for pricing update
    /// @dev callable by owner / manager (tbd)
    function updatePrice() public payable auth {
        if (oraclize_getPrice("URL") > this.balance) {
        } else {
            oraclize_query("URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");
        }
    }

    /// @notice get get current price and last update (as seconds since unix epoch)
    /// @return evePerEther current transfer rate (EVE (even.network) per ETHER (Ethereum public chain))
    /// @return lastUpdated timestamp of last price update
    function getCurrentPrice() public view returns(uint256 evePerEther, uint256 lastUpdated) {
        assert(priceEveWeiPerEther != 0 && priceLastUpdated != 0);
        // TODO: (tbd) reject if update older than x?
        return (priceEveWeiPerEther, priceLastUpdated);
    }

    /// @notice get ticket info
    /// @param ticketId id of the ticket to look up
    /// @return owner ticket owner
    /// @return price price, that has been locked for ticket
    /// @return validUntil expiration date for ticket
    /// @return value transfer value
    function getTicketInfo(uint256 ticketId) public view returns(
            address owner, uint256 price, uint256 validUntil, uint256 value) {
        owner = ticketOwner[ticketId];
        price = ticketPrice[ticketId];
        validUntil = ticketValidUntil[ticketId];
        value = ticketValue[ticketId];
    }

    /// @notice gets default updtime for tickets
    /// @return defaultUptime default updtime for new tickets
    function getDefaultTicketUptime() public view returns(uint256 defaultUptime) {
        return defaultUptime;
    }

    /// @notice get minimum value for issuing tickets
    /// @return minValue minimum transfer value
    function getTicketMinValue() public view returns(uint256 minValue) {
        return minValue;
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
