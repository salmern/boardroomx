// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/GovToken.sol";
import {EncryptedERC} from "@encrypted-erc/EncryptedERC.sol";

contract DepositEncryptedERC is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deployed addresses
        address govTokenAddr = 0x65CDaa555e6B53707E583cF55FB718d3724a0543;
        address eERCAddr = 0x5030651FC0C87e03A4AbC56D0E4d7Fc8205628F1;

        GovToken govToken = GovToken(govTokenAddr);
        EncryptedERC eERC = EncryptedERC(eERCAddr);

        //  User
        address user = vm.addr(deployerPrivateKey);

        //  Set auditor address (not uint256[2])
        eERC.setAuditorPublicKey(vm.envAddress("AUDITOR_ADDRESS"));

        // Register user ( check actual method in EncryptedERC)
        // If no register(), comment this out
        // eERC.register(user);

        //  Approve GovToken
        uint256 amount = 1000 ether;
        govToken.approve(eERCAddr, amount);

        // Deposit GovToken
        uint256[7] memory amountPCT = [amount, 0, 0, 0, 0, 0, 0];
        eERC.deposit(amount, govTokenAddr, amountPCT);

        vm.stopBroadcast();
    }
}
