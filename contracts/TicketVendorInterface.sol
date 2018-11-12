pragma solidity ^0.4.20;


interface TicketVendorInterface {
    event PriceUpdated(uint256 newPrice, uint256 updatedAt);
    event TicketConsumed(uint256 indexed ticketId);
    event TicketCreated(address indexed requester, uint256 indexed ticketId);

    /// @notice creates new ticket
    /// @dev callable by anyone
    /// emits TicketCreated
    /// @param value value to request, must be lte getTicketMinValue()
    function requestTicket(uint256 value) public;

    /// @notice call oracle for pricing update
    /// @dev callable by owner / manager (tbd)
    function updatePrice() public payable;

    /// @notice get get current price and last update (as seconds since unix epoch)
    /// @return eveWeiPerEther current transfer rate (as Wei (home network) per EVE (even.network))
    /// @return lastUpdated timestamp of last price update
    function getCurrentPrice() public view returns(uint256 eveWeiPerEther, uint256 lastUpdated, bool okay);

    /// @notice get ticket info
    /// @param ticketId id of the ticket to look up
    /// @return owner ticket owner
    /// @return price price, that has been locked for ticket
    /// @return validUntil expiration date for ticket
    /// @return value transfer value
    function getTicketInfo(uint256 ticketId) public view returns(
        address owner, uint256 price, uint256 issued, uint256 value);
}