# BoardroomX: Privacy-Preserving Governance on Avalanche

**BoardroomX** is a privacy-centric governance platform built for the [Avalanche Hack2Build: Privacy Edition](https://build.avax.network/hackathons/a0e06824-4d70-4b60-98f7-4cf5d4c28b59) hackathon. It enables secure, confidential decision-making for DAOs and corporate boardrooms on the Avalanche blockchain. Using the [Encrypted ERC-20 (eERC20)](https://github.com/ava-labs/EncryptedERC) standard in **converter mode**, BoardroomX wraps the `GovToken` ERC20 token to provide private balances and transfers, with zk-SNARKs for anonymous operations. The platform ensures sensitive governance actions (e.g., voting, budget allocations) remain confidential while maintaining on-chain auditability, ideal for organizations prioritizing privacy and compliance.

---

## 🏆 Hack2Build Privacy Edition - Round 1 Submission

This repository represents the **MVP submission for Round 1** of the Avalanche Hack2Build Privacy Edition (Deadline: **August 23, 2025**). We have successfully built and deployed a functional prototype that demonstrates the core privacy features of the eERC20 standard.

---

## 🔍 Key Features

- **🔐 Private Token Operations**: `GovToken` (ERC20) is deposited into `EncryptedERC` (converter mode) for encrypted balances, supporting private minting, transfers, and burns via homomorphic encryption (ElGamal) and zk-SNARKs.
- **🏛️ Restricted Boardroom Model**: Only designated board members can participate, with a chairman controlling membership (add/remove, transfer chairmanship).
- **🔍 Auditor Compliance**: Auditors (e.g., `0x59c2C8Aa563d835F698543D6226c9c01ACf3a866`) register with zk-SNARK proofs to monitor encrypted transactions without compromising privacy.
- **🧩 ZK Proof Generation**: Client-side proof generation for user registration (`runRegisterProof.ts`), with plans for voting/transfer proofs.
- **⚡ Avalanche Fuji Deployment**: Deployed on Fuji testnet, leveraging C-Chain's high-throughput for scalable, private transactions.
- **🗳️ Future Governance**: Planned `GovernorZK` contract for private voting and budget proposals using encrypted balances (Milestone 2).

---

## 🛠️ Technical Stack

- **Smart Contracts**: Solidity with Foundry for testing/deployment. Inherits from:
  - OpenZeppelin's Governance contracts (for future `GovernorZK`).
  - Ava Labs' EncryptedERC for eERC20 in converter mode.
- **Privacy Mechanisms**:
  - ElGamal (Eerc20) encryption for confidential balances/transfers.
  - zk-SNARKs (Circom circuits) for proof verification (registration, mint, transfer, burn).
- **Testing**: 20+ passing tests in `GovernorZK.t.sol`, `BoardManagement.t.sol`, and `GovTokenPrivacyTest.sol` (covering deposits into `EncryptedERC`).
- **Dependencies**:
  - `lib/encrypted-erc`: EncryptedERC for eERC20 functionality.
  - `lib/openzeppelin-contracts`: Governance/ERC20 utilities.
  - `lib/forge-std`: Foundry testing framework.
  - `lib/encrypted-erc/src`: TypeScript SDK for proof generation (`runRegisterProof.ts`, `registerProof.ts`).

---

## 🚀 MVP Scope (Hackathon Round 1)

The MVP demonstrates:

- **Private Deposits**: Users deposit `GovToken` into `EncryptedERC` (converter mode) for encrypted balances, tested in `GovTokenPrivacyTest.sol`.
- **Auditor Registration**: Real zk-SNARK proof generated (`runRegisterProof.ts`) for auditor (`0x59c2C8Aa563d835F698543D6226c9c01ACf3a866`).
- **Board Management**: Functional boardroom model (add/remove members, chairmanship) via `BoardManagement.t.sol`.
- **Fuji Deployment**: Contracts deployed and tested on-chain.
- **Future Plans**: `GovernorZK` (Milestone 2) for private voting/budgets, custom vote circuits, and a dApp.

---

## 🌐 Deployed Contracts (Fuji Testnet)

All contracts are live on the **Avalanche Fuji Testnet**:

| Contract | Address | SnowTrace Link |
|--------|--------|----------------|
| **GovToken** | `0x65CDaa555e6B53707E583cF55FB718d3724a0543` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x65CDaa555e6B53707E583cF55FB718d3724a0543) |
| **EncryptedERC (Converter Mode)** | `0x5030651FC0C87e03A4AbC56D0E4d7Fc8205628F1` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x5030651FC0C87e03A4AbC56D0E4d7Fc8205628F1) |
| **Registrar** | `0x0ba9DcF926FA3b5C52275007932c4E85f3804f97` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x0ba9DcF926FA3b5C52275007932c4E85f3804f97) |
| **RegistrationVerifier** | `0x4beB07281C7823F6700c0B4F4Fdf13bAF7F9Bf6A` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x4beB07281C7823F6700c0B4F4Fdf13bAF7F9Bf6A) |
| **MintVerifier** | `0x0e21Fb951DF4a79F5051dDBAeF34b84E5bD46f14` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x0e21Fb951DF4a79F5051dDBAeF34b84E5bD46f14) |
| **WithdrawVerifier** | `0x9Bc8a4B18BC7f80278aC09F82728b958a888d357` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x9Bc8a4B18BC7f80278aC09F82728b958a888d357) |
| **TransferVerifier** | `0xF630C55cCbB1ccb464fB027963ed613aD20e7f24` | [View on SnowTrace](https://testnet.snowtrace.io/address/0xF630C55cCbB1ccb464fB027963ed613aD20e7f24) |
| **BurnVerifier** | `0xF212EeE61811C30392F157d6Dd40bc610BCEe830` | [View on SnowTrace](https://testnet.snowtrace.io/address/0xF212EeE61811C30392F157d6Dd40bc610BCEe830) |

---

## 🧪 Testing

Run `forge test` to execute:

- **20 passing tests** in `GovernorZK.t.sol` and `BoardManagement.t.sol` for board management and governance (pre-deployment).
- **Privacy tests** in `GovTokenPrivacyTest.sol` for encrypted deposits.
- All tests pass, verifying deposit and registration flows.

```bash

## 🔐 ZK Proof Generation
The following TypeScript files demonstrate client-side proof generation for eERC20:

- `lib/encrypted-erc/src/runRegisterProof.ts` - Generates real ZK proofs for auditor registration
- `lib/encrypted-erc/src/registerProof.ts` - Proof generation logic using BabyJubJub and Poseidon

These scripts were used to generate the real proof for auditor `0x59c2C8Aa563d835F698543D6226c9c01ACf3a866` on Avalanche Fuji testnet.
registerProof.ts

```
import { ethers, zkit } from "hardhat";
import { poseidon } from "maci-crypto/build/ts/hashing";
import { getAddress } from "ethers";
import type { CalldataRegistrationCircuitGroth16 } from "../generated-types/zkit";

export const generateRegistrationProof = async (
  address: string,
  privateKey: bigint,
  publicKey: bigint[], // [x, y]
  chainId: bigint // Add this parameter
): Promise<CalldataRegistrationCircuitGroth16> => {
  //don't fetch from local network
  // const network = await ethers.provider.getNetwork();
  // const chainId = network.chainId;

  // Strip '0x' prefix and convert address to BigInt
  const normalizedAddress = getAddress(address);
  const addressBigInt = BigInt(normalizedAddress);
  // BabyJubJub field modulus
  const fieldModulus = BigInt("21888242871839275222246405745257275088696311157297823662689037894645226208583");
  // Compute registration hash
  const registrationHash = poseidon([chainId, privateKey, addressBigInt]); // Use passed chainId

  const input = {
    SenderPrivateKey: privateKey.toString(),
    SenderPublicKey: [
      (publicKey[0] % fieldModulus).toString(),
      (publicKey[1] % fieldModulus).toString()
    ],
    SenderAddress: addressBigInt.toString(),
    ChainID: chainId.toString(), // Use passed chainId
    RegistrationHash: registrationHash.toString(),
  };

  console.log("Circuit Input:", JSON.stringify(input, null, 2));

  const circuit = await zkit.getCircuit("RegistrationCircuit");
  const registrationCircuit = circuit as any;

  try {
    const proof = await registrationCircuit.generateProof(input);
    const calldata = await registrationCircuit.generateCalldata(proof);
    return calldata;
  } catch (error) {
    console.error("Proof generation failed:", error);
    throw error;
  }
};
 runRegisterProof.ts
```
```
import { generateRegistrationProof } from "./registerProof";
import { mulPointEscalar, inCurve, Base8 } from "@zk-kit/baby-jubjub";
import { ethers, getAddress } from "ethers";

async function main() {

    // Get the actual chain ID from the network you're deploying to
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "https://api.avax-test.network/ext/bc/C/rpc");
  const network = await provider.getNetwork();
  const chainId = network.chainId.toString();
  console.log("Chain ID:", chainId); // This should be 43113 for Avalanche testnet
  const auditorAddress = "0x59c2C8Aa563d835F698543D6226c9c01ACf3a866";
  // Validate address
  const normalizedAddress = getAddress(auditorAddress);
  // Use a valid private key within the curve's subgroup order
  const privateKey = BigInt("1234567890123456789012345678901234567890");
  // BabyJubJub subgroup order
  const curveOrder = BigInt("2736030358979909402780800718157159386076813972158567259200215660948447373041");
  // BabyJubJub field modulus
  const fieldModulus = BigInt("21888242871839275222246405745257275088696311157297823662689037894645226208583");
  if (privateKey >= curveOrder || privateKey === 0n) {
    throw new Error("Private key is out of valid range for BabyJubJub curve");
  }
  // Generate public key using Base8
  const publicKeyPoint = mulPointEscalar(Base8, privateKey);
  const publicKey: [bigint, bigint] = [
    publicKeyPoint[0] % fieldModulus,
    publicKeyPoint[1] % fieldModulus
  ];
  console.log("Public Key:", publicKey);
  console.log("Is point on curve:", inCurve(publicKey));
  if (!inCurve(publicKey)) {
    throw new Error("Public key is not on the BabyJubJub curve");
  }
  if (publicKey[0] === 0n || publicKey[1] === 0n) {
    throw new Error("Invalid public key: contains zero coordinate");
  }
  // const proof = await generateRegistrationProof(normalizedAddress, privateKey, publicKey, chainId);

  // At the end, pass the chainId:
const proof = await generateRegistrationProof(normalizedAddress, privateKey, publicKey,  BigInt(chainId.toString()));
  console.log("Registration Proof:", JSON.stringify(proof, null, 2));
}

main().catch(console.error);

```



git clone https://github.com/salmern/boardroomx.git
cd boardroomx

forge install
cd lib/encrypted-erc && npm install

Generate ZK proofs (optional - already deployed)
cd lib/encrypted-erc
npx ts-node src/runRegisterProof.ts

Note: Update DeployEncryptedERCConverter.s.sol and GovTokenPrivacy.t.sol if regenerating proofs.

forge test

Roadmap

Milestone 1: MVP Prototype
- Deployed GovToken, EncryptedERC (converter mode), Registrar, and verifiers on Fuji testnet
- Auditor registration with real zk-SNARK proof
- Encrypted deposits tested and working
- 20+ passing tests for core functionality
- Timeline: Completed by August 23, 2025
- Dependencies: Foundry, EncryptedERC, Fuji testnet
- Status: ✅ Done

Milestone 2: ZK Governance
- Deploy GovernorZK contract with ZK voting and encrypted budget proposals
- Use EncryptedERC (converter mode) for private voting power
- Implement mock ZK proofs for voting eligibility
- Timeline: August 25 – September 1, 2025
- Dependencies: Milestone 1, Circom, snarkjs
- Status: 🟡 In Progress

Milestone 3: Full ZK Integration
- Develop custom Circom circuit for anonymous voting
- Enable client-side proof generation for voting and transfers
- Integrate with eERC20 SDK
- Timeline: September 1–7, 2025
- Dependencies: EncryptedERC SDK
- Status: ⚪ Planned

Milestone 4: dApp Frontend
- Build React-based dApp for private governance
- Enable private proposal creation, voting, and balance decryption
- Connect to Avalanche C-Chain
- Timeline: September 7–14, 2025
- Dependencies: ethers.js
- Status: ⚪ Planned

Milestone 5: Audit & Mainnet
- Conduct security audit
- Run beta tests with early adopters
- Deploy to Avalanche C-Chain mainnet
- Onboard first DAOs and corporate boards
- Timeline: Post-hackathon (September 2025 onward)
- Dependencies: Funding, Codebase Accelerator
- Status: ⚪ Planned