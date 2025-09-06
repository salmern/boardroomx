// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IGovernanceCore.sol";


/// @title BoardManagement - Manages corporate board membership
/// @notice Handles adding/removing board members and access control
contract BoardManagement is IBoardManagement {
    mapping(address => bool) private _boardMembers;
    address[] private _boardMembersList;
    address public chairman;

    uint256 public constant MAX_BOARD_SIZE = 15;
    uint256 public constant MIN_BOARD_SIZE = 3;

    

    modifier onlyChairman() {
        require(msg.sender == chairman, "Only chairman can perform this action");
        _;
    }

    modifier onlyBoardMember() {
        require(_boardMembers[msg.sender], "Only board members can perform this action");
        _;
    }

    modifier validBoardSize() {
        require(_boardMembersList.length >= MIN_BOARD_SIZE, "Board too small");
        require(_boardMembersList.length <= MAX_BOARD_SIZE, "Board too large");
        _;
    }

    constructor(address[] memory initialMembers, address _chairman) {
         if (_chairman == address(0)) {
            revert("Invalid chairman address");
        }
        if (_boardMembers[_chairman]) {
            revert("Chairman already added");
        }

        // Add chairman
        _boardMembersList.push(_chairman);
        _boardMembers[_chairman] = true;
        chairman = _chairman;
        emit BoardMemberAdded(_chairman, block.timestamp);

        // Add initial members
        for (uint256 i = 0; i < initialMembers.length; i++) {
            address member = initialMembers[i];
            if (member == address(0)) {
                revert("Invalid member address");
            }
            if (_boardMembers[member]) {
                revert("Duplicate board member");
            }

            _boardMembersList.push(member);
            _boardMembers[member] = true;
            emit BoardMemberAdded(member, block.timestamp);
        }
    }

    function addBoardMember(address member) external override onlyChairman {
        require(member != address(0), "Invalid member address");
        require(!_boardMembers[member], "Already a board member");
        require(_boardMembersList.length < MAX_BOARD_SIZE, "Board at maximum size");

        _addBoardMemberInternal(member);
        emit BoardMemberAdded(member, block.timestamp);
    }

    function removeBoardMember(address member) external override onlyChairman {
        require(member != address(0), "Invalid member address");
        require(_boardMembers[member], "Not a board member");
        require(member != chairman, "Cannot remove chairman");
        require(_boardMembersList.length > MIN_BOARD_SIZE, "Cannot go below minimum size");

        _removeBoardMemberInternal(member);
        emit BoardMemberRemoved(member, block.timestamp);
    }

    function transferChairmanship(address newChairman) external onlyChairman {
        require(newChairman != address(0), "Invalid chairman address");
        require(_boardMembers[newChairman], "New chairman must be board member");
        require(newChairman != chairman, "Already chairman");

        address oldChairman = chairman;
        chairman = newChairman;

        emit BoardMembershipTransferred(oldChairman, newChairman);

        //  remove old chairman or keep as normal member
        // i will Uncomment if i want to auto-remove old chairman:
        // _removeBoardMemberInternal(oldChairman);
        // emit BoardMemberRemoved(oldChairman, block.timestamp);
    }

    

    function isBoardMember(address account) external view override returns (bool) {
        return _boardMembers[account];
    }

    function getBoardMembers() external view override returns (address[] memory) {
        return _boardMembersList;
    }

    function getBoardSize() external view override returns (uint256) {
        return _boardMembersList.length;
    }

    function isChairman(address account) external view returns (bool) {
        return account == chairman;
    }

    // Internal functions
    function _addBoardMemberInternal(address member) internal {
        _boardMembers[member] = true;
        _boardMembersList.push(member);
    }

    function _removeBoardMemberInternal(address member) internal {
        _boardMembers[member] = false;

        // Remove from array
        for (uint256 i = 0; i < _boardMembersList.length; i++) {
            if (_boardMembersList[i] == member) {
                _boardMembersList[i] = _boardMembersList[_boardMembersList.length - 1];
                _boardMembersList.pop();
                break;
            }
        }
    }

    // View functions for governance integration
    // function getBoardMemberRoot() external view returns (bytes32) {
    //     // This will be used for zkSNARK membership proofs
    //     // For now, return a simple hash of all board members
    //     return keccak256(abi.encodePacked(_boardMembersList));
    // }

}
