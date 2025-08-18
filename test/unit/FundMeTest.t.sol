// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // This is the address of the user that will be used to test the contract
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether; // 10 ETH in wei
    uint256 public MINIMUM_USD = 5e18; // 5 USD in wei
    uint256 public constant GAS_PRICE=1;

    function setUp() external {
        // This function is run before each test
        // You can set up initial conditions here
        console.log("Setting up the test environment...");
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give USER 10 ETH
    }

    // Can use this to have this cbe called in tests where we need the contract to be funded by the user
    modifier userFunded() {
        vm.prank(USER);
        fundMe.fund{value: MINIMUM_USD}();
        _;
    }

    function testMinimumUsd() public view {
        assertEq(
            fundMe.MINIMUM_USD(),
            MINIMUM_USD,
            "Minimum USD should be 5 ETH"
        );
    }

    function testOwnerIsMsgSender() public view {
        //i_owner is FundMeTest address
        console.log(fundMe.getOwner());
        // msg.sender is the address of the caller of the test function, which is also the Foundry-generated test contract address — but it’s not the same instance that deployed FundMe
        console.log(msg.sender);
        assertEq(
            fundMe.getOwner(),
            msg.sender,
            "The owner should be the address that deployed the contract"
        );
    }

    function testMinFundRevert() public {
        uint256 lessThanThreshold = 0; // 4 USD in wei
        // This will revert if the require statement in the fund function is triggered
        vm.expectRevert(abi.encodePacked(fundMe.FUND_MIN_REVERT_MESSAGE())); //Saying the next line will revert
        fundMe.fund{value: lessThanThreshold}();
    }

    function testFundUpdates() public  {
        vm.prank(USER); //Next TXN will be sent from USER address, makes it easier to test if we have predictably know which address is sending
        fundMe.fund{value: MINIMUM_USD}();
        uint256 expectedBalance = fundMe.getAddressToAmountFunded(USER);
        assertEq(MINIMUM_USD, expectedBalance);
    }

    function testAddFunderToArray() public userFunded {

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "The first funder should be the USER address");
    }


    function testOnlyOwnerCanWithdraw() public userFunded{
        vm.expectRevert(); //Next txn will revert not necessrily line
        vm.prank(USER);
        fundMe.withdraw();
    }

    //Think of tests in this way:
    //Arrange -> Act -> Assert
    function testWithdrawWithASingleFunder() public userFunded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft(); // Get the current gas left before the transaction
        console.log("Starting Gas:", gasStart);

        vm.txGasPrice(GAS_PRICE); // Set a gas price for the transaction
        console.log("Starting gas price:", GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft(); // Get the gas left after the transaction
        console.log("Ending Gas:", gasEnd);
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // Calculate the gas used
        console.log("Gas used for withdrawal:", gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance should be 0 after withdrawal");
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance,
            "Owner balance should be increased by the FundMe balance after withdrawal"
        );

    }

    function testWithdrawWithMultipleFunders() public userFunded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex=1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE); // Create a new address with 10 ETH
            fundMe.fund{value: MINIMUM_USD}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw(); //Should have spent gas? Default in anvil is 0 for gas price 
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance should be 0 after withdrawal");
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance,
            "Owner balance should be increased by the FundMe balance after withdrawal"
        );
    }


        function testWithdrawWithMultipleFundersCheaper() public userFunded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex=1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE); // Create a new address with 10 ETH
            fundMe.fund{value: MINIMUM_USD}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); //Should have spent gas? Default in anvil is 0 for gas price 
        vm.stopPrank();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0, "FundMe balance should be 0 after withdrawal");
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance,
            "Owner balance should be increased by the FundMe balance after withdrawal"
        );
    }

    //This wont pass just by running `forge test` because the contract address of the price feed is not on the local anvil chain.
    //But the contract does not live there
    //With mocks it will pass `forge test`
    function testPriceFeedVersion() public view {
        uint256 expectedVersion = 4;
        assertEq(
            fundMe.getVersion(),
            expectedVersion,
            "The version should be 4"
        );
    }
}
