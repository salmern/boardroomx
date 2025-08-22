// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { BurnCircuitGroth16Verifier } from "@encrypted-erc/verifiers/BurnCircuitGroth16Verifier.sol";
import { MintCircuitGroth16Verifier } from "@encrypted-erc/verifiers/MintCircuitGroth16Verifier.sol";
import { RegistrationCircuitGroth16Verifier } from "@encrypted-erc/verifiers/RegistrationCircuitGroth16Verifier.sol";
import { TransferCircuitGroth16Verifier } from "@encrypted-erc/verifiers/TransferCircuitGroth16Verifier.sol";
import { WithdrawCircuitGroth16Verifier } from "@encrypted-erc/verifiers/WithdrawCircuitGroth16Verifier.sol";
import { Registrar } from "@encrypted-erc/Registrar.sol";
import { EncryptedERC } from "@encrypted-erc/EncryptedERC.sol";
import { CreateEncryptedERCParams, RegisterProof, ProofPoints } from "@encrypted-erc/types/Types.sol";
import { GovToken } from "src/GovToken.sol";

contract DeployEncryptedERCConverter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 auditorPrivateKey = vm.envUint("AUDITOR_PRIVATE_KEY");
        address auditor = vm.envAddress("AUDITOR_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy GovToken
        GovToken govToken = new GovToken();
        console.log("GovToken deployed at:", address(govToken));

        // Deploy verifiers
        RegistrationCircuitGroth16Verifier registrationVerifier = new RegistrationCircuitGroth16Verifier();
        MintCircuitGroth16Verifier mintVerifier = new MintCircuitGroth16Verifier();
        WithdrawCircuitGroth16Verifier withdrawVerifier = new WithdrawCircuitGroth16Verifier();
        TransferCircuitGroth16Verifier transferVerifier = new TransferCircuitGroth16Verifier();
        BurnCircuitGroth16Verifier burnVerifier = new BurnCircuitGroth16Verifier();

        // Log verifier addresses
        console.log("RegistrationVerifier deployed at:", address(registrationVerifier));
        console.log("MintVerifier deployed at:", address(mintVerifier));
        console.log("WithdrawVerifier deployed at:", address(withdrawVerifier));
        console.log("TransferVerifier deployed at:", address(transferVerifier));
        console.log("BurnVerifier deployed at:", address(burnVerifier));

        // Deploy Registrar
        Registrar registrar = new Registrar(address(registrationVerifier));

        // Register auditor with REAL proof
        uint256[2] memory b0 = [
            uint256(0x10aa3917add01099ef76b9ed45efc7ed92690fc2f737c27032f14da5e5288646),
            uint256(0x0e7e478fb1f516fa0cef02d7aab4c159a951da17de6811dc9b17fbd383317ceb)
        ];
        uint256[2] memory b1 = [
            uint256(0x1409ea23749c4d629298e824f6d3243fad29b1632cd848cf1109aa61f7ed2763),
            uint256(0x18deafc2d1880eee662f67a8c7e39ea42e1a0f4a3f9f9f46730252c2f572ceb6)
        ];
        RegisterProof memory proof = RegisterProof({
            proofPoints: ProofPoints({
                a: [
                    uint256(0x06517a8cebcf0fc5fb80302a5d4b655c60d754c556f334d2c9e80d17ceed9f56),
                    uint256(0x213307ff538cfdf533a14eed99da2cf1ed27f3c794c0040baa0d4d4a008a0869)
                ],
                b: [b0, b1],
                c: [
                    uint256(0x231061614613394414b8a66a957251876becafc520a4ef16dbf4e35d8669271d),
                    uint256(0x1b9c41a25423306904a041010d816ddfcbf2c5d09b668d365fcbd381d0cbd8fa)
                ]
            }),
            publicSignals: [
                uint256(0x0548d612d5948c43122493428a33f86668d1219b46e8f930fffd67499451d782),
                uint256(0x29dac3dc6b89d893218d4480d7f3722ad2605560fe6ad1e060ad4d7e8e39cf45),
                uint256(0x00000000000000000000000059c2c8aa563d835f698543d6226c9c01acf3a866),
                uint256(0x000000000000000000000000000000000000000000000000000000000000a869),
                uint256(0x293f208ab4eaddd94d66253b9f862547f589b3fac3bc613b22bd65e65aa60b6a)
            ]
        });
        vm.stopBroadcast();

        vm.startBroadcast(auditorPrivateKey);
        // Add this before the register call
        console.log("Auditor address from env:", auditor);
        console.log("Transaction sender will be:", vm.addr(auditorPrivateKey));
        console.log("Addresses match:", auditor == vm.addr(auditorPrivateKey));
        console.log("About to register with proof");
        console.log("Auditor address:", auditor);
        console.log("Transaction sender:", vm.addr(auditorPrivateKey));

        registrar.register(proof);
        vm.stopBroadcast();

        vm.startBroadcast(deployerPrivateKey);

        // Deploy EncryptedERC
        CreateEncryptedERCParams memory config = CreateEncryptedERCParams({
            registrar: address(registrar),
            isConverter: true,
            name: "",
            symbol: "",
            mintVerifier: address(mintVerifier),
            withdrawVerifier: address(withdrawVerifier),
            transferVerifier: address(transferVerifier),
            burnVerifier: address(burnVerifier),
            decimals: 18
        });
        EncryptedERC eERC = new EncryptedERC(config);

        // Set auditor public key
        eERC.setAuditorPublicKey(auditor);

        // Log addresses
        console.log("Registrar deployed at:", address(registrar));
        console.log("EncryptedERC (converter) deployed at:", address(eERC));

        vm.stopBroadcast();
    }
}
