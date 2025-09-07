// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import { GovernorZK } from "../src/governance/GovernorZK.sol";
import { ProposalTypes } from "../src/governance/ProposalTypes.sol";

contract CreateProposal is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address governorAddr = vm.envAddress("GOVERNORZK_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        GovernorZK governor = GovernorZK(governorAddr);

        // Create a unique proposal ID (e.g., hash of title + timestamp)
        bytes32 proposalId = keccak256("proposal-q3-marketing-budget-2025");

        // Encode proposal data
        ProposalTypes.ProposalActions memory actions = ProposalTypes.ProposalActions({
            targets: new address[](0),
            values: new uint256[](0),
            calldatas: new bytes[](0),
            signatures: new string[](0)
        });

        ProposalTypes.EncryptedBudget memory budget = ProposalTypes.EncryptedBudget({
            budgetHash: bytes32(0), // Hash of encrypted budget data
            encryptedData: "",
            decryptionKeys: new bytes32[](0), // Keys for threshold decryption
            isDecrypted: false, // Whether budget has been revealed
            decryptedContent: ""
        });

        bytes memory proposalData = abi.encode(
            ProposalTypes.ProposalType.GENERAL, // or Budget, Sensitive, etc.
            "Q3 Marketing Budget",
            "ipfs://Qm...", // metadata
            actions,
            budget
        );

        // Call propose()
        governor.propose(proposalId, "Increase Q3 Marketing Budget by 50 BGT", proposalData);

        vm.stopBroadcast();
    }
}
