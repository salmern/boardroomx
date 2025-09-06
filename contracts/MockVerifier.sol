// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockVerifier {
    // signature compatible with the IVerifier interface (we didn't import it to avoid path issues)
    function verifyProof(
        uint256[2] calldata,
        uint256[2][2] calldata,
        uint256[2] calldata,
        uint256[] calldata
    ) external pure returns (bool) {
        return true;
    }
}
