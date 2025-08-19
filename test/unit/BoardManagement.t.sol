// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/utils/BoardManagement.sol";

contract BoardManagementTest is Test {
    BoardManagement boardMgmt;
    
    address chairman = address(0x1);
    address member1 = address(0x2);
    address member2 = address(0x3);
    address nonMember = address(0x4);
    
    function setUp() public {
        address[] memory initialMembers = new address[](2);
        initialMembers[0] = member1;
        initialMembers[1] = member2;
        
        boardMgmt = new BoardManagement(initialMembers, chairman);
    }

    function testInitialSetup() public {
        assertTrue(boardMgmt.isBoardMember(chairman));
        assertTrue(boardMgmt.isBoardMember(member1));
        assertTrue(boardMgmt.isBoardMember(member2));
        assertFalse(boardMgmt.isBoardMember(nonMember));
        
        assertEq(boardMgmt.getBoardSize(), 3);
        assertEq(boardMgmt.chairman(), chairman);
    }

    function testAddBoardMember() public {
        vm.prank(chairman);
        boardMgmt.addBoardMember(nonMember);
        
        assertTrue(boardMgmt.isBoardMember(nonMember));
        assertEq(boardMgmt.getBoardSize(), 4);
    }

    function testRemoveBoardMember() public {
        // First add a member so we have 4 total (above minimum)
        vm.prank(chairman);
        boardMgmt.addBoardMember(nonMember);
        assertEq(boardMgmt.getBoardSize(), 4);
        
        // Now we can safely remove a member
        vm.prank(chairman);
        boardMgmt.removeBoardMember(member1);
        
        assertFalse(boardMgmt.isBoardMember(member1));
        assertEq(boardMgmt.getBoardSize(), 3); // Back to minimum size
    }

    function testOnlyChairmanCanAddMembers() public {
        vm.prank(member1);
        vm.expectRevert("Only chairman can perform this action");
        boardMgmt.addBoardMember(nonMember);
    }

    function testOnlyChairmanCanRemoveMembers() public {
        vm.prank(member1);
        vm.expectRevert("Only chairman can perform this action");
        boardMgmt.removeBoardMember(member2);
    }

    function testCannotRemoveChairman() public {
        vm.prank(chairman);
        vm.expectRevert("Cannot remove chairman");
        boardMgmt.removeBoardMember(chairman);
    }

    function testCannotAddDuplicateMember() public {
        vm.prank(chairman);
        vm.expectRevert("Already a board member");
        boardMgmt.addBoardMember(member1);
    }

    function testCannotRemoveBelowMinimumSize() public {
        // Try to remove a member when we're at minimum size (3)
        vm.prank(chairman);
        vm.expectRevert("Cannot go below minimum size");
        boardMgmt.removeBoardMember(member1);
    }

    function testTransferChairmanship() public {
        vm.prank(chairman);
        boardMgmt.transferChairmanship(member1);
        
        assertEq(boardMgmt.chairman(), member1);
    }

    function testGetBoardMembers() public {
        address[] memory members = boardMgmt.getBoardMembers();
        assertEq(members.length, 3);
        
        // Check all initial members are in the list
        bool foundChairman = false;
        bool foundMember1 = false;
        bool foundMember2 = false;
        
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == chairman) foundChairman = true;
            if (members[i] == member1) foundMember1 = true;
            if (members[i] == member2) foundMember2 = true;
        }
        
        assertTrue(foundChairman);
        assertTrue(foundMember1);
        assertTrue(foundMember2);
    }
}