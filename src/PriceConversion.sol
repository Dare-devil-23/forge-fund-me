//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConversion {
    function getPrice(address priceFeedAddress) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e18);
    }

    function getConvertionRate(
        uint256 ethAmount,
        address priceFeedAddress
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeedAddress);
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUSD;
    }

    function getVersion(
        address priceFeedAddress
    ) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        return priceFeed.version();
    }
}
