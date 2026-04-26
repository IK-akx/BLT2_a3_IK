// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PriceFeedConsumer.sol";

contract PriceDependentVault {
    mapping(address => uint256) public balances;

    PriceFeedConsumer public consumer;

    uint256 public priceThreshold; // in USD (1e18)
    uint256 public staleTime;

    constructor(
        address feed,
        uint256 threshold,
        uint256 staleWindow
    ) {
        consumer = new PriceFeedConsumer(feed);
        priceThreshold = threshold;
        staleTime = staleWindow;
    }

    function deposit() external payable {
        require(msg.value > 0, "zero");

        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "not enough");

        uint256 price = consumer.getLatestPrice();
        uint256 updatedAt = consumer.getUpdatedAt();

        // stale check
        require(block.timestamp - updatedAt <= staleTime, "stale price");

        // price check
        require(price >= priceThreshold, "price too low");

        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");
    }

    function getUsdValue(uint256 ethAmount) public view returns (uint256) {
        uint256 price = consumer.getLatestPrice();
        return (ethAmount * price) / 1e18;
    }
}