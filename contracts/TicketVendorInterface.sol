pragma solidity ^0.4.20;

import "./Core.sol";


interface TicketVendorInterface {
    event TicketConsumed(uint256 indexed ticketId);
    event TicketCreated(address indexed requester, uint256 indexed ticketId);

    /// @notice invalidates ticket (delete or invalidate? (tbd))
    /// @dev callable by home bridge (tbd),
    /// emits TicketConsumed
    /// @param ticketId id of the ticket to consume
    function consumeTicket(uint256 ticketId) public;
    /// @notice creates new ticket
    /// @dev callable by anyone
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    function requestTicket(uint256 value) public;
    /// @notice set default uptime
    /// @dev callable by owner
    /// @param newDefaultUptime new value for updtime (as seconds since unix epoch)
    function setDefaultTicketUptime(uint256 newDefaultUptime) public;
    // update minimum transfer value (home network, payed in Wei)
    /// @notice creates new ticket
    /// @dev callable by owner
    /// @param newMinValue new minimum transfer value
    function setMinValue(uint256 newMinValue) public;
    /// @notice call oracle for pricing update
    /// @dev callable by owner / manager (tbd)
    function updatePrice() public payable;

    /// @notice get get current price and last update (as seconds since unix epoch)
    /// @return weiPerEve current transfer rate (as Wei (home network) per EVE (even.network))
    /// @return lastUpdated timestamp of last price update
    function getCurrentPrice() public view returns(uint256 weiPerEve, uint256 lastUpdated);
    /// @notice get ticket info
    /// @param ticketId id of the ticket to look up
    /// @return owner ticket owner
    /// @return price price, that has been locked for ticket
    /// @return validUntil expiration date for ticket
    /// @return value transfer value
    function getCurrentTicketInfo(uint256 ticketId) public view returns(
        address owner, uint256 price, uint256 validUntil, uint256 value);
    /// @notice gets default updtime for tickets
    /// @return defaultUptime default updtime for new tickets
    function getDefaultTicketUptime() public view returns(uint256);
    /// @notice get minimum value for issuing tickets
    /// @return minValue minimum transfer value
    function getTicketMinValue() public view returns(uint256);
}