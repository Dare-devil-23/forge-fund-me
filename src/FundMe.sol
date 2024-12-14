//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import {PriceConversion} from "./PriceConversion.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__WinthdrawFailed();

contract FundMe {
    using PriceConversion for uint256;
    uint256 public constant MIN_AMOUNT = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amount) private s_funderAmountMap;

    address private immutable i_owner;
    address public immutable s_priceFeedAddress;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeedAddress = priceFeedAddress;
    }

    function fund() public payable {
        if (msg.value.getConvertionRate(s_priceFeedAddress) < MIN_AMOUNT)
            revert FundMe__NotEnoughFunds();
        s_funders.push(msg.sender);
        s_funderAmountMap[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i; i < fundersLength; i++) {
            s_funderAmountMap[s_funders[i]] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (!callSuccess) revert FundMe__WinthdrawFailed();
    }

    function getVersion() public view returns (uint256) {
        return PriceConversion.getVersion(s_priceFeedAddress);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address funder
    ) external view returns (uint256) {
        return s_funderAmountMap[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
