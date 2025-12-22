// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract SimpleVoting {
    struct Proposal {
       string name;
       uint256 voteCount;
    }
    struct Voter {
        bool voted;
        uint256 vote;
    }
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal [] public proposals;
    uint256 public votingEndTime;
    uint256 endTime;

    event Voted(address indexed voter, uint256 proposalIndex);
    event VotingStarted(uint256 endTime);
    event VotingEnded(uint256 winningProposal);

    modifier onlyChairperson() {
        require(msg.sender== chairperson, "Only Chairperson can call this");
        _;
    }
    modifier onlyDuringVoting() {
        require(block.timestamp<votingEndTime, " Voting has ended");
        _;
    }
    constructor() {
        chairperson = msg.sender;
    }

    function startVoting(uint256 durationInMinutes, string[] memory proposalNames) external onlyChairperson {
        require(proposalNames.length >= 2, "Need at least 2 proposals");
        require(votingEndTime == 0, "Voting already started");
        for (uint i=0; i<proposalNames.length; i++)
             proposals.push(Proposal({
                name:proposalNames[i], voteCount:0
             }));
    votingEndTime = block.timestamp + (durationInMinutes * 1 minutes);
    emit VotingStarted(votingEndTime);
    }

    function vote(uint256 proposalIndex) external onlyDuringVoting {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal");
        sender.voted = true;
        sender.vote = proposalIndex;
        proposals[proposalIndex].voteCount++;
        emit Voted(msg.sender, proposalIndex);
    }
function getWinner() external view returns (string memory winnerName, uint256 voteCount) {
    require(block.timestamp >= votingEndTime, "Voting still in progress");
    require(votingEndTime > 0, "Voting not started");
    uint256 winningVoteCount = 0;
    uint256 winningProposal = 0;
    for (uint256 i = 0; i < proposals.length; i++) {
        if (proposals[i].voteCount > winningVoteCount) {
            winningVoteCount = proposals[i].voteCount;
            winningProposal = i;
        }
    }
    return (proposals[winningProposal].name, winningVoteCount);
}

function getProposals() external view returns (Proposal[] memory) {
    return proposals;
}
function getRemainingTime() external view returns (uint256) {
if (votingEndTime == 0 || block.timestamp >= votingEndTime) {
    return 0;
}
return votingEndTime - block.timestamp;
}
}
