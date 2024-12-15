//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Test} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

pragma solidity ^0.8.26;

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address USER = makeAddr("test user");
    uint256 constant MIN_AMOUNT = 5e18;
    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, 10e18);
    }

    function testUsersCanFundInteractions() public {
        vm.prank(USER);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
