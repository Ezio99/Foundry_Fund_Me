// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // This function is run before each test
        // You can set up initial conditions here
        console.log("Setting up the test environment...");
        fundMe = new FundMe();
    }

    function testMinimumUsd() public view {
        uint256 expectedMinimumUsd = 5e18; // 5 USD in wei
        assertEq(
            fundMe.MINIMUM_USD(),
            expectedMinimumUsd,
            "Minimum USD should be 5 ETH"
        );
    }

    function testOwnerIsMsgSender() public view {
        //i_owner is FundMeTest address
        console.log(fundMe.i_owner());
        // msg.sender is the address of the caller of the test function, which is also the Foundry-generated test contract address — but it’s not the same instance that deployed FundMe
        console.log(msg.sender);
        assertEq(
            fundMe.i_owner(),
            // msg.sender,
            address(this),
            "The owner should be the address that deployed the contract"
        );
    }

    //This wont pass just by running `forge test` because the contract address of the price feed is not on the local anvil chain.
    //But the contract does not live there
    function testPriceFeedVersion() public view {
        uint256 expectedVersion = 4;
        assertEq(
            fundMe.getVersion(),
            expectedVersion,
            "The version should be 4"
        );
    }



}
