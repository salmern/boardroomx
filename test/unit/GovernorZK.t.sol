// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/governance/GovernorZK.sol";
import "../../src/utils/BoardManagement.sol";
import "../../src/GovToken.sol";

contract GovernorZKTest is Test {
    GovernorZK governor;
    BoardManagement boardMgmt;
    GovToken govToken;
    
    address chairman = address(0x1);
    address member1 = address(0x2);
    address member2 = address(0x3);
    address member3 = address(0x4);
    address nonMember = address(0x5);
    
    bytes32 constant PROPOSAL_ID = keccak256("test-proposal-1");
    
    function setUp() public {
        // Set up board management
        address[] memory initialMembers = new address[](3);
        initialMembers[0] = member1;
        initialMembers[1] = member2;
        initialMembers[2] = member3;
        
        boardMgmt = new BoardManagement(initialMembers, chairman);
        
        // Deploy governance token
        govToken = new GovToken();
        
        // Deploy governor
        governor = new GovernorZK(address(boardMgmt), address(govToken));
    }

    function testCreateGeneralProposal() public {
        vm.prank(chairman);
        
        // Create proposal data
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
            ProposalTypes.ProposalType.GENERAL,
            "Test General Proposal",
            "ipfs://QmTestHash",
            actions,
            budget
        );
        
        bytes32 createdId = governor.propose(
            PROPOSAL_ID,
            "A test proposal for general board resolution",
            proposalData
        );
        
        assertEq(createdId, PROPOSAL_ID);
        
        // Check proposal was created
        (ProposalTypes.ProposalCore memory proposal, ) = governor.getProposalDetails(PROPOSAL_ID);
        assertEq(proposal.id, PROPOSAL_ID);
        assertEq(proposal.proposer, chairman);
        assertEq(proposal.title, "Test General Proposal");
    }

  function testCreateBudgetProposal() public {
    vm.prank(member1);
    
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
    
    bytes memory proposalData = abi.encode(
        ProposalTypes.ProposalType.BUDGET,
        "Q4 Budget Proposal",
        "ipfs://QmBudgetHash",
        actions,
        budget
    );
    
    governor.propose(
        PROPOSAL_ID,
        "Q4 budget allocation proposal",
        proposalData
    );

    ProposalTypes.EncryptedBudget memory encryptedBudget = governor.getEncryptedBudget(PROPOSAL_ID);
    // Then access individual fields
    bytes32 retrievedBudgetHash = encryptedBudget.budgetHash;
    // string memory encryptedData = encryptedBudget.encryptedData;
    bytes memory encryptedData = encryptedBudget.encryptedData;
    bool isDecrypted = encryptedBudget.isDecrypted;
    string memory decryptedContent = encryptedBudget.decryptedContent;
    assertEq(retrievedBudgetHash, budgetHash);
    assertFalse(isDecrypted);
}

    function testVotingFlow() public {
        // Create proposal
        vm.prank(chairman);
        _createTestProposal();
        
        // Check initial state
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Active));
        
        // Vote - chairman votes for
        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        // Vote - member1 votes for
        vm.prank(member1);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        // Vote - member2 votes against
        vm.prank(member2);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.Against));
        
        // Check voting results
        (, ProposalTypes.VotingResults memory results) = governor.getProposalDetails(PROPOSAL_ID);
        assertEq(results.forVotes, 2);
        assertEq(results.againstVotes, 1);
        assertEq(results.totalVotes, 3);
    }

    function testProposalPassing() public {
        vm.prank(chairman);
        _createTestProposal();
        
        // All 4 board members vote for the proposal
        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        vm.prank(member1);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        vm.prank(member2);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        vm.prank(member3);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        // Fast forward past voting period
        vm.warp(block.timestamp + 4 days);
        
        // Check proposal succeeded
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Succeeded));
        
        // Execute proposal after delay
        vm.warp(block.timestamp + 2 days); // Execution delay
        
        vm.prank(chairman);
        governor.execute(PROPOSAL_ID);
        
        // Check proposal was executed
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Executed));
    }

    function testProposalFailing() public {
        vm.prank(chairman);
        _createTestProposal();
        
        // Majority votes against
        vm.prank(chairman);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.Against));
        
        vm.prank(member1);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.Against));
        
        vm.prank(member2);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        // Fast forward past voting period
        vm.warp(block.timestamp + 4 days);
        
        // Check proposal was defeated
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Defeated));
    }

    function testOnlyBoardMembersCanPropose() public {
        vm.prank(nonMember);
        vm.expectRevert("Not a board member");
        
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
            ProposalTypes.ProposalType.GENERAL,
            "Test Proposal",
            "",
            actions,
            budget
        );
        
        governor.propose(PROPOSAL_ID, "Test proposal", proposalData);
    }

    function testOnlyBoardMembersCanVote() public {
        vm.prank(chairman);
        _createTestProposal();
        
        vm.prank(nonMember);
        vm.expectRevert("Not a board member");
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
    }

    function testCannotVoteTwice() public {
        vm.prank(chairman);
        _createTestProposal();
        
        vm.prank(member1);
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.For));
        
        vm.prank(member1);
        vm.expectRevert("Already voted");
        governor.castVote(PROPOSAL_ID, uint8(ProposalTypes.VoteType.Against));
    }

    function testCancelProposal() public {
        vm.prank(member1);
        _createTestProposal();
        
        // Proposer can cancel
        vm.prank(member1);
        governor.cancel(PROPOSAL_ID);
        
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Canceled));
    }

    function testChairmanCanCancelAnyProposal() public {
        vm.prank(member1);
        _createTestProposal();
        
        // Chairman can cancel any proposal
        vm.prank(chairman);
        governor.cancel(PROPOSAL_ID);
        
        assertEq(uint8(governor.state(PROPOSAL_ID)), uint8(IGovernor.ProposalState.Canceled));
    }

    // Helper function to create a test proposal
    function _createTestProposal() internal {
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
            ProposalTypes.ProposalType.GENERAL,
            "Test Proposal",
            "ipfs://QmTest",
            actions,
            budget
        );
        
        governor.propose(
            PROPOSAL_ID,
            "A test proposal for unit testing",
            proposalData
        );
    }
}