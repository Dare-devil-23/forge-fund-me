//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocs/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeConfig = getEthereumConfig();
        } else {
            activeConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return netWorkConfig;
    }

    function getEthereumConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return netWorkConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeConfig.priceFeedAddress != address(0)) {
            return activeConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );
        vm.stopBroadcast();

        NetworkConfig memory netWorkConfig = NetworkConfig({
            priceFeedAddress: address(mockV3Aggregator)
        });

        return netWorkConfig;
    }
}
