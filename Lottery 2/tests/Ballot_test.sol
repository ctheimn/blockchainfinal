// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/3_Ballot.sol";

contract BallotTest {

    bytes32[] proposalNames;

    Ballot ballotToTest;

    // Initialize the Ballot contract with the given proposal names
    function beforeAll () public {
        proposalNames.push(bytes32("candidate1"));
        ballotToTest = new Ballot(proposalNames);
    }

    // Test the winningProposal function
    function testWinningProposal() public {
        console.log("Running testWinningProposal");
        ballotToTest.vote(0);

        uint winningProposalIndex = ballotToTest.winningProposal();
        bytes32 winnerName = ballotToTest.winnerName();

        Assert.equal(winningProposalIndex, uint(0), "Proposal at index 0 should be the winning proposal");
        Assert.equal(winnerName, bytes32("candidate1"), "candidate1 should be the winner name");
    }

    // Test the winningProposal function with a return value
    function testWinningProposalWithReturnValue() public view returns (bool) {
        console.log("Running testWinningProposalWithReturnValue");
        return ballotToTest.winningProposal() == 0;
    }
}
