// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { GovToken } from "src/GovToken.sol";
import { EncryptedERC } from "@encrypted-erc/EncryptedERC.sol";
import { Registrar } from "@encrypted-erc/Registrar.sol";
import { RegistrationCircuitGroth16Verifier } from "@encrypted-erc/verifiers/RegistrationCircuitGroth16Verifier.sol";
import { MintCircuitGroth16Verifier } from "@encrypted-erc/verifiers/MintCircuitGroth16Verifier.sol";
import { WithdrawCircuitGroth16Verifier } from "@encrypted-erc/verifiers/WithdrawCircuitGroth16Verifier.sol";
import { TransferCircuitGroth16Verifier } from "@encrypted-erc/verifiers/TransferCircuitGroth16Verifier.sol";
import { BurnCircuitGroth16Verifier } from "@encrypted-erc/verifiers/BurnCircuitGroth16Verifier.sol";
import { CreateEncryptedERCParams, RegisterProof, ProofPoints } from "@encrypted-erc/types/Types.sol";

contract GovTokenPrivacyTest is Test {
    GovToken govToken;
    EncryptedERC eERC;
    Registrar registrar;
    address user = makeAddr("auditor");

    address auditor = address(0x59c2C8Aa563d835F698543D6226c9c01ACf3a866);

    function setUp() external {
        vm.chainId(43113);
        // Deploy verifiers
        RegistrationCircuitGroth16Verifier registrationVerifier = new RegistrationCircuitGroth16Verifier();
        MintCircuitGroth16Verifier mintVerifier = new MintCircuitGroth16Verifier();
        WithdrawCircuitGroth16Verifier withdrawVerifier = new WithdrawCircuitGroth16Verifier();
        TransferCircuitGroth16Verifier transferVerifier = new TransferCircuitGroth16Verifier();
        BurnCircuitGroth16Verifier burnVerifier = new BurnCircuitGroth16Verifier();

        // Deploy Registrar
        registrar = new Registrar(address(registrationVerifier));

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

        // Used prank to simulate the auditor calling register
        vm.prank(auditor);
        registrar.register(proof);

        // Create config
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

        // Deploy eERC
        eERC = new EncryptedERC(config);

        // Set auditor public key
        vm.prank(address(this));
        eERC.setAuditorPublicKey(auditor);

        govToken = new GovToken();
        govToken.mint(auditor, 1000 ether);

        vm.deal(auditor, 1 ether);
    }

    function testDeposit() external {
        vm.startPrank(auditor);

        govToken.approve(address(eERC), 100 ether);

        uint256[7] memory proof = [
            uint256(0x0f9e557c440fea18ac392a84f5f51aeb1803211207ead6b51b86dfe2ea4ba6fb),
            uint256(0x28e598aa0441ad02890e3637bd09580272049b46311eaca688fdefa1bf391fda),
            uint256(0x1e6bc12731f97c458b94cb2f1b0fcd34712f93c03e919e203c8d5af14bbd002a),
            uint256(0x0c4305fef5fc438f5c7ea557563031516e16d1a74f4fbfb0492332bae31197ad),
            uint256(0x0fbb0241ff0900c28e578c2f654b6ce0114c539afecce2c74c16304e339a3ecf),
            uint256(0x2771134ec5a3df2440878c290670d1dfbc66d4101936973b9410d96d68ab4c00),
            uint256(0x02ba74129a2a750788b809d4f6dc7aa23f4657c96ac5b85141a809c6064ba9df)
        ];
        eERC.deposit(100 ether, address(govToken), proof);

        assertEq(govToken.balanceOf(auditor), 900 ether);

        vm.stopPrank();
    }
}
