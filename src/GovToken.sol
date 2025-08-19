// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20Votes.sol";


contract GovToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("Boardroom Governance Token", "BGT") ERC20Permit("Boardroom Governance Token") {
        _mint(msg.sender, 1_000_000 ether);
    }

 /// @notice Mint new tokens (only owner)
    // function mint(address to, uint256 amount) external {
    //     require(msg.sender == owner, "Not authorized");
    //     _mint(to, amount);
    // }
    // Override the _update function to handle conflicts between ERC20 and ERC20Votes
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    // Override nonces to handle conflicts between ERC20Permit and Nonces
    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}

