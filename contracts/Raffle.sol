// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Raffle is ERC721, VRFConsumerBase {
    using Counters for Counters.Counter;

    uint256 private _winnerRandom;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _idCounter;
    uint256 public maxSupply;
    uint256 public revealDate;
    bool public revealed;

    // DATA FOR MUMBAI TESTNET
    bytes32 internal constant keyHash =
        0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
    uint256 internal constant LinkFee = 1 * 10**14; // 0.0001 LINK
    address private constant VRFCoordinator =
        0x8C7382F9D8f56b33781fE506E897a4F1e2d17255;
    address private constant LinkToken =
        0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    constructor(uint256 _maxSupply, uint256 _revealDate)
        ERC721("Raffle", "RFF")
        VRFConsumerBase(VRFCoordinator, LinkToken)
    {
        maxSupply = _maxSupply;
        revealDate = _revealDate;
    }

    function mintTicket(address to) public {
        require(!revealed, "Winner has already been revealed");
        uint256 current = _idCounter.current();
        require(current < maxSupply, "There are no tickets left");

        _idCounter.increment();
        _safeMint(to, current);
    }

    function pickWinner() public {
        require(
            block.timestamp > revealDate,
            "Reveal date hasn't been reached"
        );

        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK"
        );
        return requestRandomness(keyHash, LinkFee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        _winnerRandom = randomness;
    }

    function winner() public view returns (uint256) {
        require(revealed, "Winner has not been revealed yet");

        return _winnerRandom % _idCounter.current();
    }
}
