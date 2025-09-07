// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { EncryptedERC } from "@encrypted-erc/EncryptedERC.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployDepositWithProof is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address eERCAddress = vm.envAddress("ENCRYPTED_ERC_ADDRESS");
        address govTokenAddress = vm.envAddress("GOV_TOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        EncryptedERC eERC = EncryptedERC(eERCAddress);
        IERC20 govToken = IERC20(govTokenAddress);

        console2.log("Depositing to EncryptedERC at:", address(eERC));
        console2.log("GovToken address:", govTokenAddress);
        console2.log("Depositor:", msg.sender);

        // Approve deposit
        govToken.approve(address(eERC), 100 ether);

        // I used the FIRST 7 elements of publicSignals from my runDepositProof.ts
        uint256[7] memory proof = [
            0x0000000000000000000000000000000000000000000000000000000000007a69, // amount
            0x2ebcafff72a7c371820ef6f0b2f3b73b66d5d43d20395c69601bb82d67f2515a,
            0x0548d612d5948c43122493428a33f86668d1219b46e8f930fffd67499451d782,
            0x29dac3dc6b89d893218d4480d7f3722ad2605560fe6ad1e060ad4d7e8e39cf45,
            0x064efd1240e13b310c3f3e40f61d4765d4c00f7938a6cbba2e7bf1f23fc24f49,
            0x197b7803d371cd224785ccd24acea95e2be69ce1b9b0cac7dd7bb0240553f315,
            0x28d3484bc06890e908e46b7cb2d4759bc1596d44effb8518f7f1f1e1867adc5e
        ];

        uint256 amount = 100 ether;

        console2.log("Submitting deposit with ZK proof...");
        eERC.deposit(amount, govTokenAddress, proof);

        console2.log("Deposit successful!");
        console2.log("Check Snowtrace for transaction details");

        vm.stopBroadcast();
    }
}
