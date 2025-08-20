// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IGovernanceCore.sol";
import "../utils/BoardManagement.sol";
import "./ProposalTypes.sol";

/// @title GovernorZK - Corporate Governance with zkSNARK Anonymous Voting
/// @notice Enables board members to vote anonymously on sensitive corporate proposals
contract GovernorZK is IGovernor {
    using ProposalTypes for ProposalTypes.ProposalType;

    // State variables
    BoardManagement public immutable boardManagement;
    IVerifier public zkVerifier; // Will be set later for zkSNARK proofs
    IEERC20 public governanceToken; // Will be eERC20 on Avalanche

    mapping(bytes32 => ProposalTypes.ProposalCore) public proposals;
    mapping(bytes32 => ProposalTypes.VotingResults) public votingResults;
    mapping(bytes32 => ProposalTypes.EncryptedBudget) private encryptedBudgets;
    mapping(bytes32 => ProposalTypes.ProposalActions) private proposalActions;

    // Anti-double voting (will use zkSNARK nullifiers later)
    mapping(bytes32 => mapping(address => bool)) public hasVoted;
    mapping(bytes32 => bool) public usedNullifiers; // For anonymous voting

    // Governance parameters
    uint256 public constant PROPOSAL_THRESHOLD = 1; // Min tokens to propose
    uint256 public constant DEFAULT_QUORUM = 51; // 51% default quorum

    // Events (from IGovernor interface)

    modifier onlyBoardMember() {
        require(boardManagement.isBoardMember(msg.sender), "Not a board member");
        _;
    }

    modifier validProposal(bytes32 proposalId) {
        require(proposals[proposalId].id != bytes32(0), "Proposal does not exist");
        _;
    }

    constructor(address _boardManagement, address _governanceToken) {
        require(_boardManagement != address(0), "Invalid board management address");
        require(_governanceToken != address(0), "Invalid token address");

        boardManagement = BoardManagement(_boardManagement);
        governanceToken = IEERC20(_governanceToken);
    }

    /// @notice Create a new proposal
    function propose(bytes32 proposalId, string memory description, bytes memory proposalData)
        external
        override
        onlyBoardMember
        returns (bytes32)
    {
        require(proposalId != bytes32(0), "Invalid proposal ID");
        require(proposals[proposalId].id == bytes32(0), "Proposal already exists");
        require(bytes(description).length > 0, "Empty description");

        // Decode proposal data
        (
            ProposalTypes.ProposalType proposalType,
            string memory title,
            string memory metadataURI,
            ProposalTypes.ProposalActions memory actions,
            ProposalTypes.EncryptedBudget memory budget
        ) = abi.decode(
            proposalData,
            (ProposalTypes.ProposalType, string, string, ProposalTypes.ProposalActions, ProposalTypes.EncryptedBudget)
        );

        uint256 votingPeriod = ProposalTypes.getVotingPeriod(proposalType);
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + votingPeriod;

        // Create proposal
        proposals[proposalId] = ProposalTypes.ProposalCore({
            id: proposalId,
            proposer: msg.sender,
            proposalType: proposalType,
            title: title,
            description: description,
            metadataURI: metadataURI,
            startTime: startTime,
            endTime: endTime,
            executionDelay: ProposalTypes.getExecutionDelay(proposalType),
            executed: false,
            canceled: false
        });

        // Set voting parameters
        votingResults[proposalId] = ProposalTypes.VotingResults({
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            totalVotes: 0,
            quorumRequired: ProposalTypes.getQuorumRequirement(proposalType),
            approvalThreshold: ProposalTypes.getApprovalThreshold(proposalType)
        });

        // Store actions if any
        if (actions.targets.length > 0) {
            proposalActions[proposalId] = actions;
        }

        // Store encrypted budget if provided
        if (budget.budgetHash != bytes32(0)) {
            encryptedBudgets[proposalId] = budget;
            emit ProposalTypes.BudgetEncrypted(proposalId, budget.budgetHash, block.timestamp);
        }

        emit ProposalCreated(proposalId, msg.sender, startTime, endTime, description);
        emit ProposalTypes.ProposalCreated(proposalId, msg.sender, proposalType, startTime, endTime);

        return proposalId;
    }

    /// @notice Cast a vote on a proposal (basic version, will add zkSNARK later)
    function castVote(bytes32 proposalId, uint8 support)
        external
        override
        onlyBoardMember
        validProposal(proposalId)
        returns (uint256)
    {
        ProposalTypes.ProposalCore storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(support <= 2, "Invalid vote type");

        // For now, each board member has equal weight (1 vote)
        // Later this will be based on encrypted token balance
        uint256 weight = 1;

        hasVoted[proposalId][msg.sender] = true;

        ProposalTypes.VotingResults storage results = votingResults[proposalId];

        if (support == uint8(ProposalTypes.VoteType.For)) {
            results.forVotes += weight;
        } else if (support == uint8(ProposalTypes.VoteType.Against)) {
            results.againstVotes += weight;
        } else {
            results.abstainVotes += weight;
        }

        results.totalVotes += weight;

        emit VoteCast(msg.sender, proposalId, support, weight, "");
        emit ProposalTypes.VoteCast(
            proposalId,
            msg.sender,
            ProposalTypes.VoteType(support),
            weight,
            bytes32(0) // No nullifier yet
        );

        return weight;
    }

    /// @notice Execute a successful proposal
    function execute(bytes32 proposalId) external override validProposal(proposalId) {
        ProposalTypes.ProposalCore storage proposal = proposals[proposalId];
        require(state(proposalId) == ProposalState.Succeeded, "Proposal not ready for execution");
        require(!proposal.executed, "Already executed");

        // Check execution delay
        require(block.timestamp >= proposal.endTime + proposal.executionDelay, "Execution delay not met");

        proposal.executed = true;

        // Execute actions if any
        ProposalTypes.ProposalActions storage actions = proposalActions[proposalId];
        for (uint256 i = 0; i < actions.targets.length; i++) {
            (bool success,) = actions.targets[i].call{ value: actions.values[i] }(actions.calldatas[i]);
            require(success, "Execution failed");
        }

        emit ProposalExecuted(proposalId);
        // emit ProposalTypes.ProposalStateChanged(proposalId, ProposalTypes.ProposalState.Executed, block.timestamp);
    }

    /// @notice Get the current state of a proposal

    function state(bytes32 proposalId)
        public
        view
        override
        validProposal(proposalId)
        returns (
            IGovernor.ProposalState // ← Explicitly use IGovernor's
        )
    {
        ProposalTypes.ProposalCore storage proposal = proposals[proposalId];

        if (proposal.canceled) {
            return IGovernor.ProposalState.Canceled;
        }

        if (proposal.executed) {
            return IGovernor.ProposalState.Executed;
        }

        if (block.timestamp < proposal.startTime) {
            return IGovernor.ProposalState.Pending;
        }

        if (block.timestamp <= proposal.endTime) {
            return IGovernor.ProposalState.Active;
        }

        // Voting ended — check quorum & approval
        ProposalTypes.VotingResults storage results = votingResults[proposalId];
        uint256 totalBoardMembers = boardManagement.getBoardSize();

        // Quorum check
        if ((results.totalVotes * 100) / totalBoardMembers < results.quorumRequired) {
            return IGovernor.ProposalState.Defeated;
        }

        uint256 totalForApproval = results.forVotes + results.againstVotes;
        if (totalForApproval == 0) {
            return IGovernor.ProposalState.Defeated;
        }

        if ((results.forVotes * 100) / totalForApproval >= results.approvalThreshold) {
            return IGovernor.ProposalState.Succeeded;
        }

        return IGovernor.ProposalState.Defeated;
    }

    /// @notice Cancel a proposal (only by proposer or chairman)
    function cancel(bytes32 proposalId) external validProposal(proposalId) {
        ProposalTypes.ProposalCore storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer || boardManagement.isChairman(msg.sender), "Not authorized to cancel");
        require(!proposal.executed, "Cannot cancel executed proposal");

        proposal.canceled = true;
    }

    // Utility functions
    function getProposalDetails(bytes32 proposalId)
        external
        view
        returns (ProposalTypes.ProposalCore memory proposal, ProposalTypes.VotingResults memory results)
    {
        return (proposals[proposalId], votingResults[proposalId]);
    }

    function getProposalActions(bytes32 proposalId) external view returns (ProposalTypes.ProposalActions memory) {
        return proposalActions[proposalId];
    }

    function getEncryptedBudget(bytes32 proposalId) external view returns (ProposalTypes.EncryptedBudget memory) {
        return encryptedBudgets[proposalId];
    }

    function getBoardVotingPower() external view returns (uint256) {
        return boardManagement.getBoardSize();
    }

    // For future zkSNARK integration
    function setZKVerifier(address _verifier) external {
        require(boardManagement.isChairman(msg.sender), "Only chairman can set verifier");
        zkVerifier = IVerifier(_verifier);
    }

    // Budget decryption (for approved budget proposals)
    function decryptBudget(bytes32 proposalId, string memory decryptedContent)
        // bytes memory proof
        external
        onlyBoardMember
        validProposal(proposalId)
    {
        require(this.state(proposalId) == ProposalState.Executed, "Proposal not executed");

        ProposalTypes.EncryptedBudget storage budget = encryptedBudgets[proposalId];
        require(budget.budgetHash != bytes32(0), "No encrypted budget");
        require(!budget.isDecrypted, "Already decrypted");

        // Verify decryption proof
        bytes32 computedHash = keccak256(abi.encodePacked(decryptedContent));
        require(computedHash == budget.budgetHash, "Invalid decryption");

        budget.isDecrypted = true;
        budget.decryptedContent = decryptedContent;

        emit ProposalTypes.BudgetDecrypted(proposalId, decryptedContent, block.timestamp);
    }
}
