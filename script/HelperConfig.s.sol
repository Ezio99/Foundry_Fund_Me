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

    constructor() {
        //Every chain has its id
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }



    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }


    // Cant be pure since we use vm
    function getAnvilEthConfig() public  returns (NetworkConfig memory) {
        //Deploy mock
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        //Return mock address
        NetworkConfig memory anvilEthConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });

        return anvilEthConfig;
    }
}
