// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal verifier interface matching snarkjs Groth16 verifier signature.
interface IVerifier {
    function verifyProof(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        uint256[] calldata input
    ) external view returns (bool);
}

/// @notice Minimal encrypted token interface (POC integration point).
interface IEncryptedERC20 {
    function encryptedBalanceOf(address who) external view returns (bytes memory ciphertext);
    function transfer(address to, uint256 value) external returns (bool);
}

contract GovernorZK {
    struct Proposal {
        bytes32 id;
        address proposer;
        string encryptedCid;
        uint64 start;
        uint64 end;
        bool finalized;
        bool passed;
    }

    IVerifier public verifier;
    IEncryptedERC20 public eToken;

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => mapping(bytes32 => bool)) public nullifierUsed;
    mapping(bytes32 => uint256) public yesVotes;
    mapping(bytes32 => uint256) public noVotes;

    event ProposalCreated(bytes32 indexed id, address indexed proposer, string encryptedCid, uint64 start, uint64 end);
    event VoteSubmitted(bytes32 indexed id, bytes32 nullifierHash, bool voteYes);
    event ProposalFinalized(bytes32 indexed id, bool passed);

    constructor(address _verifier, address _eToken) {
        verifier = IVerifier(_verifier);
        eToken = IEncryptedERC20(_eToken);
    }

    function propose(bytes32 id, string calldata encryptedCid, uint64 votingPeriodSeconds) external {
        require(proposals[id].start == 0, "ID used");
        uint64 start = uint64(block.timestamp);
        uint64 end = start + votingPeriodSeconds;
        proposals[id] = Proposal(id, msg.sender, encryptedCid, start, end, false, false);
        emit ProposalCreated(id, msg.sender, encryptedCid, start, end);
    }

    /// publicInputs layout (MVP): [uint256(proposalId), uint256(nullifierHash)]
    function vote(
        bytes32 proposalId,
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        uint256[] calldata publicInputs,
        bool voteYes_
    ) external {
        Proposal storage p = proposals[proposalId];
        require(p.start != 0, "no proposal");
        require(block.timestamp >= p.start && block.timestamp <= p.end, "not active");

        require(publicInputs.length >= 2, "bad inputs");
        require(uint256(proposalId) == publicInputs[0], "pid mismatch");

        bool ok = verifier.verifyProof(a, b, c, publicInputs);
        require(ok, "invalid proof");

        bytes32 nullifierHash = bytes32(publicInputs[1]);
        require(!nullifierUsed[proposalId][nullifierHash], "double vote");
        nullifierUsed[proposalId][nullifierHash] = true;

        if (voteYes_) yesVotes[proposalId] += 1;
        else noVotes[proposalId] += 1;

        emit VoteSubmitted(proposalId, nullifierHash, voteYes_);
    }

    function finalize(bytes32 proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(p.start != 0, "no proposal");
        require(block.timestamp > p.end, "not ended");
        require(!p.finalized, "finalized");

        p.finalized = true;
        p.passed = (yesVotes[proposalId] >= noVotes[proposalId]);
        emit ProposalFinalized(proposalId, p.passed);
    }
}