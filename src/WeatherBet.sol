// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/ChainlinkClient.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract WeatherBet is ChainlinkClient, ConfirmedOwner {
    uint256 public number;
    using Chainlink for Chainlink.Request;
    address private oracleAddress;
    bytes32 private jobId;
    uint256 private fee;
    bytes32 public lastRequest;

    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0xE4aB69C077896252FAFBD49EFD26B5D171A32410);
        setOracleAddress(0x14bc7F6Da6cA3E072793c185e01a76E62341CC61);
        setJobId("a8356f48569c434eaa4ac5fcb4db5cc0");
        setFeeInHundredthsOfLink(0); // 0 LINK
    }

    function request() public {
        Chainlink.Request memory req = _buildOperatorRequest(
            jobId,
            this.fulfill.selector
        );

        // DEFINE THE REQUEST PARAMETERS (example)
        req._add("method", "GET");
        req._add(
            "url",
            "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH&tsyms=USD,EUR"
        );
        req._add(
            "headers",
            '["content-type", "application/json", "set-cookie", "sid=14A52"]'
        );
        req._add("body", "");
        req._add("contact", ""); // PLEASE ENTER YOUR CONTACT INFO. this allows us to notify you in the event of any emergencies related to your request (ie, bugs, downtime, etc.). example values: 'derek_linkwellnodes.io' (Discord handle) OR 'derek@linkwellnodes.io' OR '+1-617-545-4721'

        // The following curl command simulates the above request parameters:
        // curl 'https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH&tsyms=USD,EUR' --request 'GET' --header 'content-type: application/json' --header 'set-cookie: sid=14A52'

        // PROCESS THE RESULT (example)
        req._add("path", "ETH,USD");
        req._addInt("multiplier", 10 ** 18);

        // Send the request to the Chainlink oracle
        lastRequest = _sendOperatorRequest(req, fee);
    }

    uint256 public response;

    // Receive the result from the Chainlink oracle
    event RequestFulfilled(bytes32 indexed requestId);

    function fulfill(
        bytes32 requestId,
        uint256 data
    ) public recordChainlinkFulfillment(requestId) {
        // Process the oracle response
        // emit RequestFulfilled(requestId);    // (optional) emits this event in the on-chain transaction logs, allowing Web3 applications to listen for this transaction
        response = data; // example value: 1875870000000000000000 (1875.87 before "multiplier" is applied)
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function setOracleAddress(address _oracleAddress) public onlyOwner {
        oracleAddress = _oracleAddress;
        _setChainlinkOracle(_oracleAddress);
    }

    function setJobId(string memory _jobId) public onlyOwner {
        jobId = bytes32(bytes(_jobId));
    }

    function getJobId() public view onlyOwner returns (string memory) {
        return string(abi.encodePacked(jobId));
    }

    function getFeeInHundredthsOfLink()
        public
        view
        onlyOwner
        returns (uint256)
    {
        return (fee * 100) / LINK_DIVISIBILITY;
    }

    function setFeeInHundredthsOfLink(
        uint256 _feeInHundredthsOfLink
    ) public onlyOwner {
        setFeeInJuels((_feeInHundredthsOfLink * LINK_DIVISIBILITY) / 100);
    }

    function setFeeInJuels(uint256 _feeInJuels) public onlyOwner {
        fee = _feeInJuels;
    }
}
