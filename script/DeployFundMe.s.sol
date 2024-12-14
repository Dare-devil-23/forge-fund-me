// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

pragma solidity ^0.8.26;

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig config = new HelperConfig();
        address priceFeedAddress = config.activeConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
