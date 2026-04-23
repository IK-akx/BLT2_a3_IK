// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/task2/MockERC20.sol";
import "../../src/task2/Vault.sol";
import "./HelperConfig.s.sol";

contract DeployMockAndVault is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        HelperConfig helper = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helper.getConfig();

        vm.startBroadcast(deployerKey);

        MockERC20 token = new MockERC20();

        Vault vault = new Vault(
            IERC20(address(token)),
            config.vaultName,
            config.vaultSymbol,
            deployer
        );

        vm.stopBroadcast();

        console2.log("Deployer:", deployer);
        console2.log("MockERC20:", address(token));
        console2.log("Vault:", address(vault));
        console2.log("Chain ID:", block.chainid);
    }
}