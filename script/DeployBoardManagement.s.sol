// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import {BoardManagement} from "../src/utils/BoardManagement.sol";

contract DeployBoardManagement is Script {
    function run() external {
        // Load deployer's private key from .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get chairman address: from .env or default to deployer
        address chairman = vm.envOr("CHAIRMAN_ADDRESS", vm.addr(deployerPrivateKey));

        // Load initial members from .env
       
        address member1 = vm.envAddress("MEMBER1");
        address member2 = vm.envAddress("MEMBER2");

        // Define initial board members
        address[] memory initialMembers = new address[](2);
        initialMembers[0] = member1;
        initialMembers[1] = member2;

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the BoardManagement contract
        BoardManagement board = new BoardManagement(initialMembers, chairman);

        // Log deployment info
        console.log("BoardManagement deployed at:", address(board));
        console.log("Chairman:", chairman);
        console.log("Initial board size:", initialMembers.length + 1);

        // End transaction broadcast
        vm.stopBroadcast();
    }
}