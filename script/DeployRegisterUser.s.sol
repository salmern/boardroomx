// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Registrar} from "@encrypted-erc/Registrar.sol";
import {RegisterProof, ProofPoints} from "@encrypted-erc/types/Types.sol";

contract DeployRegisterUser is Script {
    function run() external {
        // Use the PRIVATE_KEY that controls 0x72F4... (your wallet)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address registrarAddress = vm.envAddress("REGISTRAR_ADDRESS"); // 0x0ba9...4f97

        vm.startBroadcast(deployerPrivateKey);

        Registrar registrar = Registrar(registrarAddress);

        // ✅ Updated Proof Points from your new runRegisterProof.ts output
        uint256[2] memory a = [
            0x0b71e9a2ff140e714442ede10218f45660bddee9bf597e1570e60f00c9e61c46,
            0x1e8ae690da0d0234fe6b0acb4b0cee347ad800dd33bb972b929b641493c9af0b
        ];

        uint256[2][2] memory b = [
            [
                0x062a3a2b333cc68d8878e9f53eaf1f363b2cb7e45262984d1428bffd6c19e726,
                0x1b870a1c4ddd17b2266025ac29ec459446a0febc2c14d4f25aafbd6cf9364ebe
            ],
            [
                0x11d3e5c0f5b9715db7f6f6548d44f947457362dcc6b75e27db1bf99a7fc73322,
                0x24e43620b7fff2fcec1bd5a20651fd68c32c117bc8d2e394e8c523e85ec0311d
            ]
        ];

        uint256[2] memory c = [
            0x026849477db6cc5dd3a3e3c910a128a5403110d7468c851b72620caa21fb30c6,
            0x28783cc002f72854a2a80bebc11d480d6a2261f7528807ace30df30ad6e8445a
        ];

        // ✅ Updated Public Signals (for your address 0x72F4...)
        uint256[5] memory publicSignals = [
            0x0548d612d5948c43122493428a33f86668d1219b46e8f930fffd67499451d782,
            0x29dac3dc6b89d893218d4480d7f3722ad2605560fe6ad1e060ad4d7e8e39cf45,
            0x00000000000000000000000072f41e41b4c080989da452bc8b9f6858b66e712e, // Your address
            0x000000000000000000000000000000000000000000000000000000000000a869,
            0x141bd86cefe57c19073ceca7453d2d42f05ac2f33b97c87a1423407ea1c278da
        ];

        // Build the RegisterProof struct
        RegisterProof memory proof = RegisterProof({
            proofPoints: ProofPoints({a: a, b: b, c: c}),
            publicSignals: publicSignals
        });

        console2.log("Registering user with ZK proof...");
        console2.log("Registrar:", registrarAddress);
        console2.log("Registering for:", 0x72F41e41b4c080989da452bc8B9f6858b66E712e);
        console2.log("Transaction sender (msg.sender):", msg.sender);

        registrar.register(proof);

        console2.log("User registered successfully!");
        console2.log("You can now deposit private tokens.");

        vm.stopBroadcast();
    }
}