// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        string vaultName;
        string vaultSymbol;
    }

    uint256 internal constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 internal constant BASE_SEPOLIA_CHAIN_ID = 84532;

    function getConfig() external view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;

        if (chainId == ETH_SEPOLIA_CHAIN_ID || chainId == BASE_SEPOLIA_CHAIN_ID) {
            return NetworkConfig({
                vaultName: vm.envString("VAULT_NAME"),
                vaultSymbol: vm.envString("VAULT_SYMBOL")
            });
        }

        revert("Unsupported network");
    }
}