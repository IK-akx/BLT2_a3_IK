// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        );

    function decimals() external view returns (uint8);
}

contract PriceFeedConsumer {
    AggregatorV3Interface public priceFeed;

    constructor(address feed) {
        priceFeed = AggregatorV3Interface(feed);
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();
        require(price > 0, "invalid price");

        uint8 decimals = priceFeed.decimals();

        // normalize to 1e18
        return uint256(price) * (10 ** (18 - decimals));
    }

    function getUpdatedAt() public view returns (uint256) {
        (, , , uint256 updatedAt, ) = priceFeed.latestRoundData();
        return updatedAt;
    }
}