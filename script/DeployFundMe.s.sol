// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{

    address constant PRICE_FEED_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Sepolia ETH/USD Price Feed 

    
    function run() external returns (FundMe) {
        //Before broadcast, wont send this
        HelperConfig  helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}