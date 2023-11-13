// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public participants;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;

    bytes32 internal keyHash; 
    uint internal fee;        // fee to get random number
    uint public randomResult;

    event PlayerEntered(address indexed player, uint amount);
    event WinnerPicked(address indexed winner, uint amount);

    constructor()
        VRFConsumerBase(
            // Update with the latest Chainlink VRF Coordinator and LINK token addresses
            0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D,
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB
        ) {
            keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
            fee = 0.25 * 10 ** 18; // 0.25 LINK
            lotteryId = 1;
        }

    function getRandomNumber() public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 /*requestId*/, uint randomness) internal override {
        randomResult = randomness;
        payWinner();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return participants;
    }

    function enter() public payable {
        require(msg.value > 0.01 ether, "Minimum entry is 0.01 ether");
        participants.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, msg.value);
    }

    function pickWinner() public onlyOwner {
        getRandomNumber();
    }

    function payWinner() internal {
        require(participants.length > 0, "No participants in the lottery");
        
        uint index = randomResult % participants.length;
        address payable winner = participants[index];
        uint prizeAmount = address(this).balance;

        winner.transfer(prizeAmount);
        emit WinnerPicked(winner, prizeAmount);

        lotteryHistory[lotteryId] = winner;
        lotteryId++;
        
        delete participants;
    }
}
