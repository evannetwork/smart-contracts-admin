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
    mapping(uint256 => uint256) public ticketIssued;
    mapping(uint256 => address) public ticketOwner;
    mapping(uint256 => uint256) public ticketPrice;
    mapping(uint256 => uint256) public ticketValue;
    uint256 private priceEveWeiPerEther = 0;
    uint256 private priceLastUpdated = 0;
    uint256 private minValue = 1 ether;

    /// @notice callback for oraclize queries
    /// @dev https://docs.oraclize.it
    /// @param result query result, new price
    function __callback(bytes32, string result) public {
        assert(msg.sender == oraclize_cbAddress());
        priceEveWeiPerEther = convertToWei(result);
        priceLastUpdated = now;

        PriceUpdated(priceEveWeiPerEther, priceLastUpdated);
    }

    /// @notice invalidates ticket (delete or invalidate? (tbd))
    /// @dev callable by home bridge (tbd),
    /// emits TicketConsumed
    /// @param ticketId id of the ticket to consume
    function consumeTicket(uint256 ticketId) public auth {
        delete ticketIssued[ticketId];
        delete ticketOwner[ticketId];
        delete ticketPrice[ticketId];
        delete ticketValue[ticketId];
    }

    /// @notice creates new ticket
    /// @dev callable by anyone
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    function requestTicket(uint256 value) public {
        assert(value >= getTicketMinValue());
        uint256 ticketId = ticketCount++;
        var (price, , okay) = getCurrentPrice();
        assert(okay);

        ticketIssued[ticketId] = now;
        ticketOwner[ticketId] = msg.sender;
        ticketPrice[ticketId] = price;
        ticketValue[ticketId] = value;

        TicketCreated(msg.sender, ticketId);
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
            oraclize_query("URL", "json(https://api.gdax.com/products/ETH-EUR/TICKER).PRICE");
        }
    }

    /// @notice get get current price and last update (as seconds since unix epoch)
    /// @return evePerEther current transfer rate (EVE (even.network) per ETHER (Ethereum public chain))
    /// @return lastUpdated timestamp of last price update
    function getCurrentPrice() public view returns(
        uint256 evePerEther, uint256 lastUpdated, bool okay) {
        if (priceEveWeiPerEther != 0 && priceLastUpdated != 0) {
            okay = true;
        }
        // TODO: (tbd) reject if update older than x?
        return (priceEveWeiPerEther, priceLastUpdated, okay);
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
