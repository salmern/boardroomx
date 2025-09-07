// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import { GovernorZK } from "../src/governance/GovernorZK.sol";
import { BoardManagement } from "../src/utils/BoardManagement.sol";

contract DeployGovernorZK is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address boardManagementAddress = vm.envAddress("BOARD_MANAGEMENT_ADDRESS");
        address encryptedERCAddress = vm.envAddress("ENCRYPTED_ERC_ADDRESS"); // Using eERC20 for voting power

        vm.startBroadcast(deployerPrivateKey);

        GovernorZK governor = new GovernorZK(boardManagementAddress, encryptedERCAddress);

        console.log("GovernorZK deployed at:", address(governor));

        vm.stopBroadcast();
    }
}
