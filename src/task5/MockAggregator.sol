// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockAggregator {
    int256 private s_price;
    uint8 private s_decimals;
    uint256 private s_updatedAt;

    constructor(int256 initialPrice, uint8 decimals_) {
        s_price = initialPrice;
        s_decimals = decimals_;
        s_updatedAt = block.timestamp;
    }

    function setPrice(int256 newPrice) external {
        s_price = newPrice;
        s_updatedAt = block.timestamp;
    }

    function setStale(uint256 time) external {
        s_updatedAt = time;
    }

    function decimals() external view returns (uint8) {
        return s_decimals;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        )
    {
        return (0, s_price, 0, s_updatedAt, 0);
    }
}