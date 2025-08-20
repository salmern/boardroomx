// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { GovToken } from "src/GovToken.sol";
import { GovernorZK } from "src/governance/GovernorZK.sol";
import { ProposalTypes } from "src/governance/ProposalTypes.sol";
import { BoardManagement } from "src/utils/BoardManagement.sol";
import { IGovernor } from "openzeppelin-contracts/governance/IGovernor.sol"; 

contract GovernorZKTest is Test {
    GovernorZK governor;
    BoardManagement boardMgmt;
    GovToken govToken;

    address chairman = address(0x1);
    address member1 = address(0x2);
    address member2 = address(0x3);
    address member3 = address(0x4);
    address nonMember = address(0x5);

    // Unique proposal IDs to prevent state pollution
    bytes32 constant PROPOSAL_ID_GENERAL = keccak256("general-proposal");
    bytes32 constant PROPOSAL_ID_BUDGET = keccak256("budget-proposal");
    bytes32 constant PROPOSAL_ID_CANCEL = keccak256("cancel-proposal");
    bytes32 constant PROPOSAL_ID_PASS = keccak256("pass-proposal");
    bytes32 constant PROPOSAL_ID_FAIL = keccak256("fail-proposal");
    bytes32 constant PROPOSAL_ID_VOTE_FLOW = keccak256("vote-flow-proposal");
    bytes32 constant PROPOSAL_ID_DOUBLE_VOTE = keccak256("double-vote-proposal");
    bytes32 constant PROPOSAL_ID_VOTE_ACCESS = keccak256("vote-access-proposal");

    function setUp() public {
        // Label addresses for better traces
        vm.label(chairman, "Chairman");
        vm.label(member1, "Member1");
        vm.label(member2, "Member2");
        vm.label(member3, "Member3");
        vm.label(nonMember, "NonMember");

        // Set up board management (3 members + chairman as proposer)
        address[] memory initialMembers = new address[](3);
        initialMembers[0] = member1;
        initialMembers[1] = member2;
        initialMembers[2] = member3;

        boardMgmt = new BoardManagement(initialMembers, chairman);

        // Deploy governance token
        govToken = new GovToken(); // 1M BGT minted to msg.sender (this contract)

        uint256 initialSupply = 1000 ether;

        // Use Forge cheatcode to give token balances
        deal(address(govToken), chairman, initialSupply);
        deal(address(govToken), member1, initialSupply);
        deal(address(govToken), member2, initialSupply);
        deal(address(govToken), member3, initialSupply);

        // Delegate votes to enable voting power
        vm.prank(chairman);
        govToken.delegate(chairman);

        vm.prank(member1);
        govToken.delegate(member1);

        vm.prank(member2);
        govToken.delegate(member2);

        vm.prank(member3);
        govToken.delegate(member3);

        // Deploy governor
        governor = new GovernorZK(address(boardMgmt), address(govToken));
    }

    /// @dev Helper to create a general proposal. Caller must `vm.prank(proposer)` first.
    function _createTestProposalWithId(bytes32 proposalId) internal {
        ProposalTypes.ProposalActions memory actions = ProposalTypes.ProposalActions({
            targets: new address[](0),
            values: new uint256[](0),
            calldatas: new bytes[](0),
            signatures: new string[](0)
        });

        ProposalTypes.EncryptedBudget memory budget = ProposalTypes.EncryptedBudget({
            budgetHash: bytes32(0),
            encryptedData: "",
            decryptionKeys: new bytes32[](0),
            isDecrypted: false,
            decryptedContent: ""
        });

        bytes memory proposalData =
            abi.encode(ProposalTypes.ProposalType.GENERAL, "Test Proposal", "ipfs://QmTest", actions, budget);

      
        governor.propose(proposalId, "A test proposal for unit testing", proposalData);
    }

    // === TESTS ===

    function testCreateGeneralProposal() public {
        ProposalTypes.ProposalActions memory actions = ProposalTypes.ProposalActions({
            targets: new address[](0),
            values: new uint256[](0),
            calldatas: new bytes[](0),
            signatures: new string[](0)
        });

        ProposalTypes.EncryptedBudget memory budget = ProposalTypes.EncryptedBudget({
            budgetHash: bytes32(0),
            encryptedData: "",
            decryptionKeys: new bytes32[](0),
            isDecrypted: false,
            decryptedContent: ""
        });

        bytes memory proposalData = abi.encode(
            ProposalTypes.ProposalType.GENERAL, "Test General Proposal", "ipfs://QmTestHash", actions, budget
        );

        vm.prank(chairman);
        bytes32 createdId =
            governor.propose(PROPOSAL_ID_GENERAL, "A test proposal for general board resolution", proposalData);

        assertEq(createdId, PROPOSAL_ID_GENERAL);

        (ProposalTypes.ProposalCore memory proposal,) = governor.getProposalDetails(PROPOSAL_ID_GENERAL);
        assertEq(proposal.id, PROPOSAL_ID_GENERAL);
        assertEq(proposal.proposer, chairman);
        assertEq(proposal.title, "Test General Proposal");
        assertEq(proposal.description, "A test proposal for general board resolution");
        assertEq(uint8(proposal.proposalType), uint8(ProposalTypes.ProposalType.GENERAL));
        assertEq(proposal.metadataURI, "ipfs://QmTestHash");
    }

    function testCreateBudgetProposal() public {
        bytes32 budgetHash = keccak256("encrypted-budget-data");

        ProposalTypes.ProposalActions memory actions = ProposalTypes.ProposalActions({
            targets: new address[](0),
            values: new uint256[](0),
            calldatas: new bytes[](0),
            signatures: new string[](0)
        });

        ProposalTypes.EncryptedBudget memory budget = ProposalTypes.EncryptedBudget({
            budgetHash: budgetHash,
            encryptedData: "encrypted-data-placeholder",
            decryptionKeys: new bytes32[](0),
            isDecrypted: false,
            decryptedContent: ""
        });

        bytes memory proposalData =
            abi.encode(ProposalTypes.ProposalType.BUDGET, "Q4 Budget Proposal", "ipfs://QmBudgetHash", actions, budget);

        vm.prank(member1);
        bytes32 createdId = governor.propose(PROPOSAL_ID_BUDGET, "Q4 budget allocation proposal", proposalData);

        assertEq(createdId, PROPOSAL_ID_BUDGET);

        ProposalTypes.EncryptedBudget memory storedBudget = governor.getEncryptedBudget(PROPOSAL_ID_BUDGET);
        assertEq(storedBudget.budgetHash, budgetHash);
        assertFalse(storedBudget.isDecrypted);

        (ProposalTypes.ProposalCore memory proposal,) = governor.getProposalDetails(PROPOSAL_ID_BUDGET);
        assertEq(uint8(proposal.proposalType), uint8(ProposalTypes.ProposalType.BUDGET));
    }

    function testVotingFlow() public {
        vm.prank(chairman);
        _createTestProposalWithId(PROPOSAL_ID_VOTE_FLOW);

        assertEq(uint8(governor.state(PROPOSAL_ID_VOTE_FLOW)), uint8(IGovernor.ProposalState.Active));

        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID_VOTE_FLOW, uint8(ProposalTypes.VoteType.For));

        vm.prank(member1);
        governor.castVote(PROPOSAL_ID_VOTE_FLOW, uint8(ProposalTypes.VoteType.For));

        vm.prank(member2);
        governor.castVote(PROPOSAL_ID_VOTE_FLOW, uint8(ProposalTypes.VoteType.Against));

        (, ProposalTypes.VotingResults memory results) = governor.getProposalDetails(PROPOSAL_ID_VOTE_FLOW);
        assertEq(results.forVotes, 2);
        assertEq(results.againstVotes, 1);
        assertEq(results.totalVotes, 3);
    }

    function testProposalPassing() public {
        vm.prank(chairman);
        _createTestProposalWithId(PROPOSAL_ID_PASS);

        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID_PASS, uint8(ProposalTypes.VoteType.For));

        vm.prank(member1);
        governor.castVote(PROPOSAL_ID_PASS, uint8(ProposalTypes.VoteType.For));

        vm.prank(member2);
        governor.castVote(PROPOSAL_ID_PASS, uint8(ProposalTypes.VoteType.For));

        vm.prank(member3);
        governor.castVote(PROPOSAL_ID_PASS, uint8(ProposalTypes.VoteType.For));

        vm.warp(block.timestamp + 4 days);

        assertEq(uint8(governor.state(PROPOSAL_ID_PASS)), uint8(IGovernor.ProposalState.Succeeded));

        vm.warp(block.timestamp + 2 days);

        vm.prank(chairman);
        governor.execute(PROPOSAL_ID_PASS);

        assertEq(uint8(governor.state(PROPOSAL_ID_PASS)), uint8(IGovernor.ProposalState.Executed));
    }

    function testProposalFailing() public {
        vm.prank(chairman);
        _createTestProposalWithId(PROPOSAL_ID_FAIL);

        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID_FAIL, uint8(ProposalTypes.VoteType.Against));

        vm.prank(member1);
        governor.castVote(PROPOSAL_ID_FAIL, uint8(ProposalTypes.VoteType.Against));

        vm.prank(member2);
        governor.castVote(PROPOSAL_ID_FAIL, uint8(ProposalTypes.VoteType.For));

        vm.warp(block.timestamp + 4 days);

        assertEq(uint8(governor.state(PROPOSAL_ID_FAIL)), uint8(IGovernor.ProposalState.Defeated));
    }

    function testOnlyBoardMembersCanPropose() public {
        ProposalTypes.ProposalActions memory actions = ProposalTypes.ProposalActions({
            targets: new address[](0),
            values: new uint256[](0),
            calldatas: new bytes[](0),
            signatures: new string[](0)
        });

        ProposalTypes.EncryptedBudget memory budget = ProposalTypes.EncryptedBudget({
            budgetHash: bytes32(0),
            encryptedData: "",
            decryptionKeys: new bytes32[](0),
            isDecrypted: false,
            decryptedContent: ""
        });

        bytes memory proposalData =
            abi.encode(ProposalTypes.ProposalType.GENERAL, "Test Proposal", "ipfs://placeholder", actions, budget);

        vm.prank(nonMember);
        vm.expectRevert("Not a board member");
        governor.propose(PROPOSAL_ID_GENERAL, "Test proposal", proposalData);
    }

    function testOnlyBoardMembersCanVote() public {
        vm.prank(chairman);
        _createTestProposalWithId(PROPOSAL_ID_VOTE_ACCESS);

        vm.prank(nonMember);
        vm.expectRevert("Not a board member");
        governor.castVote(PROPOSAL_ID_VOTE_ACCESS, uint8(ProposalTypes.VoteType.For));
    }

    function testCannotVoteTwice() public {
        vm.prank(chairman);
        _createTestProposalWithId(PROPOSAL_ID_DOUBLE_VOTE);

        vm.prank(member1);
        governor.castVote(PROPOSAL_ID_DOUBLE_VOTE, uint8(ProposalTypes.VoteType.For));

        vm.prank(member1);
        vm.expectRevert("Already voted");
        governor.castVote(PROPOSAL_ID_DOUBLE_VOTE, uint8(ProposalTypes.VoteType.Against));
    }

    function testCancelProposal() public {
        vm.prank(member1);
        _createTestProposalWithId(PROPOSAL_ID_CANCEL);

        vm.prank(member1);
        governor.cancel(PROPOSAL_ID_CANCEL);

        assertEq(uint8(governor.state(PROPOSAL_ID_CANCEL)), uint8(IGovernor.ProposalState.Canceled));
    }

    function testChairmanCanCancelAnyProposal() public {
        vm.prank(member1);
        _createTestProposalWithId(PROPOSAL_ID_CANCEL);

        vm.prank(chairman);
        governor.cancel(PROPOSAL_ID_CANCEL);

        assertEq(uint8(governor.state(PROPOSAL_ID_CANCEL)), uint8(IGovernor.ProposalState.Canceled));
    }
}
