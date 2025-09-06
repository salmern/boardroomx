// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.30;

// import {EncryptedERC} from "encrypted-erc/src/EncryptedERC.sol"; 
// import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

// contract EncryptedERCFactory {
//     address public immutable implementation;

//     event EncryptedERCProxyDeployed(address proxy, address owner);

//     constructor(address _implementation) {
//         implementation = _implementation;
//     }

//     function createProxy(address owner) external returns (address proxy) {
//         proxy = Clones.clone(implementation);

//         // call initialize() on the clone if the original has one
//         (bool ok, ) = proxy.call(abi.encodeWithSignature("initialize(address)", owner));
//         require(ok, "Initialization failed");

//         emit EncryptedERCProxyDeployed(proxy, owner);
//     }
// }
