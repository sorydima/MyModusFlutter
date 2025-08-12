// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Escrow {
    struct Order {
        uint256 id;
        address buyer;
        address seller;
        bytes32 orderHash;
        uint256 amountWei;
        bool released;
        bool refunded;
    }

    address public admin;
    uint256 public nextId;
    mapping(uint256 => Order) public orders;
    event OrderCreated(uint256 indexed id, address buyer, address seller, bytes32 orderHash, uint256 amountWei);
    event OrderReleased(uint256 indexed id);
    event OrderRefunded(uint256 indexed id);

    constructor() {
        admin = msg.sender;
        nextId = 1;
    }

    function createOrder(address seller, bytes32 orderHash) external payable returns (uint256) {
        require(msg.value > 0, "value required");
        uint256 id = nextId++;
        orders[id] = Order(id, msg.sender, seller, orderHash, msg.value, false, false);
        emit OrderCreated(id, msg.sender, seller, orderHash, msg.value);
        return id;
    }

    function release(uint256 id) external {
        Order storage o = orders[id];
        require(msg.sender == admin || msg.sender == o.buyer, "not authorized");
        require(!o.released && !o.refunded, "already closed");
        o.released = true;
        payable(o.seller).transfer(o.amountWei);
        emit OrderReleased(id);
    }

    function refund(uint256 id) external {
        Order storage o = orders[id];
        require(msg.sender == admin || msg.sender == o.seller, "not authorized");
        require(!o.released && !o.refunded, "already closed");
        o.refunded = true;
        payable(o.buyer).transfer(o.amountWei);
        emit OrderRefunded(id);
    }

    function getOrder(uint256 id) external view returns (Order memory) {
        return orders[id];
    }
}
