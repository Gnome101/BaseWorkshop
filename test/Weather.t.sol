// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {WeatherBet} from "../src/WeatherBet.sol";

contract WeatherTest is Test {
    WeatherBet public weather;
    address chainlinkOracle = 0x14bc7F6Da6cA3E072793c185e01a76E62341CC61;

    function setUp() public {
        weather = new WeatherBet();
    }

    function testFulfill() public {
        weather.request();

        bytes32 requestId = weather.lastRequest();
        // Call fulfill as if from Chainlink oracle
        vm.prank(chainlinkOracle); // Mocks the `msg.sender`
        weather.fulfill(requestId, 10);

        // Assert the outcome to confirm behavior
        // e.g., check state change or events emitted
    }
}
