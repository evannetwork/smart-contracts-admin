pragma solidity ^0.4.0;

import './AbstractENS.sol';

/**
 * The ClaimsENS registry contract.
 */
contract ClaimsENS is AbstractENS {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
        bytes32 parent;
    }

    mapping(address=>bool) public acceptedResolvers;
    mapping(bytes32=>Record) records;

    // Permits modifications only by the owner of the specified node.
    modifier only_owner(bytes32 node) {
        if (records[node].owner != msg.sender) throw;
        _;
    }
    modifier only_parent_owner(bytes32 node) {
        if (records[records[node].parent].owner != msg.sender) throw;
        _;
    }

    /**
     * Constructs a new ClaimsENS registrar.
     */
    function ClaimsENS() {
        acceptedResolvers[0] = true;
        records[0].owner = msg.sender;
    }

    /**
     * Returns the address that owns the specified node.
     */
    function owner(bytes32 node) constant returns (address) {
        return records[node].owner;
    }

    function parent(bytes32 node) constant returns (bytes32) {
        return records[node].parent;
    }

    /**
     * Returns the address of the resolver for the specified node.
     */
    function resolver(bytes32 node) constant returns (address) {
        return records[node].resolver;
    }

    /**
     * Returns the TTL of a node, and any records associated with it.
     */
    function ttl(bytes32 node) constant returns (uint64) {
        return records[node].ttl;
    }

    /**
     * Transfers ownership of a node to a new address. May only be called by the current
     * owner of the node.
     * @param node The node to transfer ownership of.
     * @param owner The address of the new owner.
     */
    function setOwner(bytes32 node, address owner) only_owner(node) {
        Transfer(node, owner);
        records[node].owner = owner;
    }

    /**
     * Transfers ownership of a subnode keccak256(node, label) to a new address. May only be
     * called by the owner of the parent node.
     * @param node The parent node.
     * @param label The hash of the label specifying the subnode.
     * @param owner The address of the new owner.
     */
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) only_owner(node) {
        var subnode = keccak256(node, label);
        NewOwner(node, label, owner);
        records[subnode].owner = owner;
        records[subnode].parent = node;
    }

    /**
     * Sets the resolver address for the specified node.
     * @param node The node to update.
     * @param resolver The address of the resolver.
     */
    function setResolver(bytes32 node, address resolver) only_parent_owner(node) {
        assert(acceptedResolvers[resolver]);
        NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    /**
     * Sets the TTL for the specified node.
     * @param node The node to update.
     * @param ttl The TTL in seconds.
     */
    function setTTL(bytes32 node, uint64 ttl) only_owner(node) {
        NewTTL(node, ttl);
        records[node].ttl = ttl;
    }

    function setAcceptedResolverState(address resolver, bool accept) public {
        assert(records[0].owner == msg.sender);
        acceptedResolvers[resolver] = accept;
    }
}
