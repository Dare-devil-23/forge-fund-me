// SPDX-License-Identifier: MIT

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.26;

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("test user");
    uint256 constant MIN_AMOUNT = 5e18;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, 10e18);
    }

    function testMinUsd() public view {
        assertEq(fundMe.MIN_AMOUNT(), MIN_AMOUNT);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testReverTransfer() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFuningStateUpdates() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testSenderAddress() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        uint256 statingAccountBalance = address(fundMe).balance;
        uint256 statingOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingAccountBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingAccountBalance, 0);
        assertEq(
            endingOwnerBalance,
            statingOwnerBalance + statingAccountBalance
        );
    }

    function testMultipleFunders() public funded {
        for (uint160 i = 1; i < 10; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 intiialAccountBalance = address(fundMe).balance;
        uint256 intiialOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingAccountBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingAccountBalance, 0);
        assertEq(
            endingOwnerBalance,
            intiialOwnerBalance + intiialAccountBalance
        );
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
}
