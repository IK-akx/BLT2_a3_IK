// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../../src/task2/MockERC20.sol";
import "../../src/task2/Vault.sol";

contract InteractVault is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(deployerKey);

        address tokenAddress = vm.envAddress("TASK3_TOKEN_ADDRESS");
        address vaultAddress = vm.envAddress("TASK3_VAULT_ADDRESS");

        MockERC20 token = MockERC20(tokenAddress);
        Vault vault = Vault(vaultAddress);

        vm.startBroadcast(deployerKey);

        token.mint(user, 1000 ether);
        token.approve(vaultAddress, 500 ether);
        vault.deposit(200 ether, user);

        token.approve(vaultAddress, 100 ether);
        vault.harvest(100 ether);

        vault.withdraw(50 ether, user, user);

        vm.stopBroadcast();

        console2.log("User:", user);
        console2.log("Token:", tokenAddress);
        console2.log("Vault:", vaultAddress);
    }
}
