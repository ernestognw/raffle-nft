// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Raffle is ERC721, VRFConsumerBase {
    using Counters for Counters.Counter;

    uint256 public winnerRandomSeed;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _idCounter;
    uint256 public maxSupply;
    uint256 public revealDate;
    bool public revealed;

    // DATA FOR RINKEBY TESTNET
    bytes32 internal constant keyHash =
        0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    uint256 internal constant LinkFee = 1 * 10**17; // 0.01 LINK
    address private constant VRFCoordinator =
        0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
    address private constant LinkToken =
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    constructor(uint256 _maxSupply, uint256 _revealDate)
        public
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

    function pickWinner() public returns (bytes32 requestId) {
        require(
            block.timestamp > revealDate,
            "Reveal date hasn't been reached"
        );

        require(LINK.balanceOf(address(this)) >= LinkFee, "Not enough LINK");
        return requestRandomness(keyHash, LinkFee);
    }

    function fulfillRandomness(bytes32, uint256 randomness)
        internal
        override
    {
        require(!revealed, "Winner has already been revealed");
        revealed = true;
        winnerRandomSeed = randomness;
    }

    function winner() public view returns (uint256) {
        require(revealed, "Winner has not been revealed yet");

        return winnerRandomSeed % _idCounter.current();
    }
}
