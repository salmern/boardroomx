// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ProposalTypes - Defines different types of corporate proposals
library ProposalTypes {
    enum ProposalType {
        GENERAL,           // General board resolutions
        BUDGET,           // Budget approvals with encryption
        EXECUTIVE_HIRE,   // C-level executive hiring
        STRATEGIC,        // Major strategic decisions
        MERGER,           // Merger & acquisition proposals
        DIVIDEND,         // Dividend distribution
        GOVERNANCE        // Governance parameter changes
    }

    // enum ProposalState {
    //     Pending,    // Proposal created, voting not started
    //     Active,     // Voting period active
    //     Defeated,   // Voting failed
    //     Succeeded,  // Voting passed
    //     Executed,   // Proposal executed
    //     Canceled,  // Proposal cancelled
    //     Expired     // Voting period expired without execution
    // }

    enum VoteType {
        Against,    // Vote against the proposal
        For,        // Vote for the proposal
        Abstain     // Abstain from voting
    }

    struct ProposalCore {
        bytes32 id;                    // Unique proposal identifier
        address proposer;              // Address of the proposer
        ProposalType proposalType;     // Type of proposal
        string title;                  // Short title
        string description;            // Detailed description
        string metadataURI;           // IPFS URI for additional data
        uint256 startTime;            // Voting start timestamp
        uint256 endTime;              // Voting end timestamp
        uint256 executionDelay;       // Delay before execution after success
        bool executed;                // Whether proposal has been executed
        bool canceled;               // Whether proposal was cancelled
    }

    struct VotingResults {
        uint256 forVotes;         // Total votes in favor
        uint256 againstVotes;     // Total votes against  
        uint256 abstainVotes;     // Total abstain votes
        uint256 totalVotes;       // Total voting power that participated
        uint256 quorumRequired;   // Quorum threshold for this proposal
        uint256 approvalThreshold; // Approval threshold (e.g., 51%, 67%)
    }

    struct EncryptedBudget {
        bytes32 budgetHash;           // Hash of encrypted budget data
        bytes encryptedData;          // Encrypted budget details
        bytes32[] decryptionKeys;     // Keys for threshold decryption
        bool isDecrypted;             // Whether budget has been revealed
        string decryptedContent;      // Revealed budget (after approval)
    }

    struct ProposalActions {
        address[] targets;            // Contract addresses to call
        uint256[] values;            // ETH values to send
        bytes[] calldatas;           // Function call data
        string[] signatures;         // Function signatures
    }

    // Events
    event ProposalCreated(
        bytes32 indexed proposalId,
        address indexed proposer,
        ProposalType indexed proposalType,
        uint256 startTime,
        uint256 endTime
    );

    event VoteCast(
        bytes32 indexed proposalId,
        address indexed voter,
        VoteType indexed voteType,
        uint256 weight,
        bytes32 nullifierHash  // For anonymous voting
    );

  
    event BudgetEncrypted(
        bytes32 indexed proposalId,
        bytes32 budgetHash,
        uint256 timestamp
    );

    event BudgetDecrypted(
        bytes32 indexed proposalId,
        string budgetDetails,
        uint256 timestamp
    );

    // Helper functions
    function getQuorumRequirement(ProposalType proposalType) 
        internal 
        pure 
        returns (uint256) 
    {
        if (proposalType == ProposalType.GOVERNANCE) return 67; // 67% for governance changes
        if (proposalType == ProposalType.MERGER) return 75;     // 75% for M&A
        if (proposalType == ProposalType.EXECUTIVE_HIRE) return 60; // 60% for executive hires
        if (proposalType == ProposalType.BUDGET) return 51;     // 51% for budgets
        return 51; // Default 51% for other proposals
    }

    function getApprovalThreshold(ProposalType proposalType) 
        internal 
        pure 
        returns (uint256) 
    {
        if (proposalType == ProposalType.GOVERNANCE) return 67;
        if (proposalType == ProposalType.MERGER) return 75;
        if (proposalType == ProposalType.EXECUTIVE_HIRE) return 60;
        return 51; // Default simple majority
    }

    function getVotingPeriod(ProposalType proposalType) 
        internal 
        pure 
        returns (uint256) 
    {
        if (proposalType == ProposalType.GOVERNANCE) return 7 days;
        if (proposalType == ProposalType.MERGER) return 14 days;    // Longer for major decisions
        if (proposalType == ProposalType.BUDGET) return 5 days;
        return 3 days; // Default voting period
    }

    function getExecutionDelay(ProposalType proposalType) 
        internal 
        pure 
        returns (uint256) 
    {
        if (proposalType == ProposalType.GOVERNANCE) return 2 days;
        if (proposalType == ProposalType.MERGER) return 7 days;     // Longer delay for M&A
        return 1 days; // Default execution delay
    }
}