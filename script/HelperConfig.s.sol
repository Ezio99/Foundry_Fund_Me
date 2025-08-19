// 1. Deploy mocks when on local anvil chain
// 2. Keep track of contract addresses across different chains

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed; //Eth/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    uint32 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint8 public constant ANVIL_DECIMALS = 8;
    int256 public constant ANVIL_INITIAL_PRICE = 2000e8;

    constructor() {
        //Every chain has its id
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    // Cant be pure since we use vm
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            //If we already have a mock deployed, return it
            return activeNetworkConfig;
        }

        //Deploy mock
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(ANVIL_DECIMALS, ANVIL_INITIAL_PRICE);
        vm.stopBroadcast();

        //Return mock address
        NetworkConfig memory anvilEthConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});

        return anvilEthConfig;
    }
}
