// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/task5/PriceFeedConsumer.sol";

contract DeployPriceFeed is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(key);

        PriceFeedConsumer consumer = new PriceFeedConsumer(
            0x694AA1769357215DE4FAC081bf1f309aDC325306 // Chainlink ETH/USD
        );

        vm.stopBroadcast();

        console2.log("PriceFeedConsumer deployed at:", address(consumer));
    }
}