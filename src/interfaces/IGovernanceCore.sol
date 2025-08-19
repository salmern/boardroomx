// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IVerifier - zkSNARK proof verification interface
interface IVerifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) external view returns (bool);
}

/// @title IEERC20 - Avalanche encrypted ERC20 interface
interface IEERC20 {
    function balanceOf(address account) external view returns (uint256);
    function encryptedBalanceOf(address account) external view returns (bytes memory);
    function verifyEncryptedBalance(bytes memory proof) external view returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @title IGovernor - Core governance interface
interface IGovernor {
    enum ProposalState {
        Pending,
        Active,
        Defeated,
        Succeeded,
        Executed,
        Canceled
    }

    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalCore {
        bytes32 id;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        bool canceled;
    }

    event ProposalCreated(
        bytes32 indexed proposalId,
        address indexed proposer,
        uint256 startTime,
        uint256 endTime,
        string description
    );

    event VoteCast(
        address indexed voter,
        bytes32 indexed proposalId,
        uint8 support,
        uint256 weight,
        string reason
    );

    event ProposalExecuted(bytes32 indexed proposalId);

    function propose(
        bytes32 proposalId,
        string memory description,
        bytes memory proposalData
    ) external returns (bytes32);

    function castVote(bytes32 proposalId, uint8 support) external returns (uint256);

    function execute(bytes32 proposalId) external;

    function state(bytes32 proposalId) external view returns (ProposalState);
}

/// @title IBoardManagement - Board member management
interface IBoardManagement {
    event BoardMemberAdded(address indexed member, uint256 timestamp);
    event BoardMemberRemoved(address indexed member, uint256 timestamp);
    event BoardMembershipTransferred(address indexed from, address indexed to);

    function addBoardMember(address member) external;
    function removeBoardMember(address member) external;
    function isBoardMember(address account) external view returns (bool);
    function getBoardMembers() external view returns (address[] memory);
    function getBoardSize() external view returns (uint256);
}

/// @title IEncryptedProposal - Budget encryption interface
interface IEncryptedProposal {
    struct EncryptedBudget {
        bytes32 hash;           // Hash of encrypted data
        bytes encryptedData;    // Encrypted budget details
        bytes32[] decryptionKeys; // Threshold decryption keys
        bool decrypted;         // Whether budget has been revealed
    }

    event BudgetEncrypted(bytes32 indexed proposalId, bytes32 budgetHash);
    event BudgetDecrypted(bytes32 indexed proposalId, string budgetDetails);

    function submitEncryptedBudget(
        bytes32 proposalId,
        bytes32 budgetHash,
        bytes memory encryptedData
    ) external;

    function decryptBudget(
        bytes32 proposalId,
        string memory decryptedBudget,
        bytes memory proof
    ) external;
}