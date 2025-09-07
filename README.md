# BoardroomX: Privacy-Preserving Governance on Avalanche

**BoardroomX** is a privacy-centric governance platform built for the [Avalanche Hack2Build: Privacy Edition](https://build.avax.network/hackathons/a0e06824-4d70-4b60-98f7-4cf5d4c28b59) hackathon. It enables secure, confidential decision-making for DAOs and corporate boardrooms on the Avalanche blockchain. Using the [Encrypted ERC-20 (eERC20)](https://github.com/ava-labs/EncryptedERC) standard in **converter mode**, BoardroomX wraps the `GovToken` ERC20 token to provide private balances and transfers, with zk-SNARKs for anonymous operations. The platform ensures sensitive governance actions (e.g., voting, budget allocations) remain confidential while maintaining on-chain auditability, ideal for organizations prioritizing privacy and compliance.

---

## 🏆 Hack2Build Privacy Edition - Round 2 Submission

This repository represents the **progress update for Round 2** of the Avalanche Hack2Build Privacy Edition (Deadline: **September 7, 2025**). We have advanced our roadmap by building a functional private governance system with real on-chain interactions and a polished frontend.

---

## 🔍 Key Features

- **🔐 Private Token Operations**: `GovToken` (ERC20) is deposited into `EncryptedERC` (converter mode) for encrypted balances, supporting private minting, transfers, and burns via homomorphic encryption (ElGamal) and zk-SNARKs.
- **🏛️ Restricted Boardroom Model**: Only designated board members can participate, with a chairman controlling membership (add/remove, transfer chairmanship).
- **🔍 Auditor Compliance**: Auditors (e.g., `0x59c2C8Aa563d835F698543D6226c9c01ACf3a866`) register with zk-SNARK proofs to monitor encrypted transactions without compromising privacy.
- **🧩 ZK Proof Generation**: Client-side proof generation for user registration (`runRegisterProof.ts`), with plans for voting/transfer proofs.
- **⚡ Avalanche Fuji Deployment**: Deployed on Fuji testnet, leveraging C-Chain's high-throughput for scalable, private transactions.
- **🗳️ Private Governance**: Built `GovernorZK` contract for private voting and budget proposals using encrypted balances.
- **📱 Interactive dApp**: Built a React-based frontend that connects to MetaMask, displays on-chain proposals, and simulates private voting.
- **💸 Real Private Deposit**: Successfully executed a **real deposit** of `0.3 BGT` into `EncryptedERC` on Fuji testnet.

---

## 🛠️ Technical Stack

- **Smart Contracts**: Solidity with Foundry for testing/deployment. Inherits from:
  - OpenZeppelin's Governance contracts (for `GovernorZK`).
  - Ava Labs' EncryptedERC for eERC20 in converter mode.
- **Privacy Mechanisms**:
  - ElGamal encryption for confidential balances/transfers.
  - zk-SNARKs (Circom circuits) for proof verification (registration, mint, transfer, burn).
- **Frontend**: React + Framer Motion + ethers.js
- **Testing**: 20+ passing tests in `GovernorZK.t.sol`, `BoardManagement.t.sol`, and `GovTokenPrivacyTest.sol`.
- **Dependencies**:
  - `lib/encrypted-erc`: EncryptedERC for eERC20 functionality.
  - `lib/openzeppelin-contracts`: Governance/ERC20 utilities.
  - `lib/forge-std`: Foundry testing framework.
  - `lib/encrypted-erc/src`: TypeScript SDK for proof generation (`runRegisterProof.ts`, `registerProof.ts`).

---

## 🚀 Progress on Roadmap (Hackathon Round 2)

The MVP demonstrated in Round 1 has been extended with real governance functionality:

- ✅ **Private Deposits**: Users deposit `GovToken` into `EncryptedERC` (converter mode) for encrypted balances, tested and now **executed on-chain**.
- ✅ **Auditor Registration**: Real zk-SNARK proof generated (`runRegisterProof.ts`) for auditor (`0x59c2C8Aa563d835F698543D6226c9c01ACf3a866`).
- ✅ **Board Management**: Functional boardroom model (add/remove members, chairmanship) via `BoardManagement.t.sol`.
- ✅ **Fuji Deployment**: Contracts deployed and tested on-chain.
- ✅ **GovernorZK**: Deployed and verified `GovernorZK` contract for private voting and proposals.
- ✅ **On-Chain Proposal**: Created a real proposal via `propose()` in `GovernorZK`.
- ✅ **Frontend dApp**: Built a responsive dApp that connects wallet, shows proposals, and simulates private voting.
- ✅ **Real Private Deposit**: Executed a real `deposit()` transaction to `EncryptedERC` with approved BGT tokens.

---

## 🌐 Deployed Contracts (Fuji Testnet)

All contracts are live on the **Avalanche Fuji Testnet** and verified on Snowtrace:

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
| **BoardManagement** | `0xEDAc2cB20c7f7d9A6570B3401D0961341F57b221` | [View on SnowTrace](https://testnet.snowtrace.io/address/0xEDAc2cB20c7f7d9A6570B3401D0961341F57b221) |
| **GovernorZK** | `0x261d07040d300A454C6567CE0ed4175A5ac73291` | [View on SnowTrace](https://testnet.snowtrace.io/address/0x261d07040d300A454C6567CE0ed4175A5ac73291) |

---

## 🧪 Testing

Run `forge test` to execute:

- **20+ passing tests** in `GovernorZK.t.sol`, `BoardManagement.t.sol`, and `GovTokenPrivacyTest.sol`.
- All tests pass, verifying deposit, registration, and governance flows.

---

## 🔐 ZK Proof Generation

The following TypeScript files demonstrate client-side proof generation for eERC20:

- `lib/encrypted-erc/src/runRegisterProof.ts` - Generates real ZK proofs for auditor registration
- `lib/encrypted-erc/src/registerProof.ts` - Proof generation logic using BabyJubJub and Poseidon
- `lib/encrypted-erc/src/runDepositProof.ts` -  Generates real ZK proofs for deposit

These scripts were used to generate the real proof for auditor `0x59c2C8Aa563d835F698543D6226c9c01ACf3a866` on Avalanche Fuji testnet.

---

## 📄 On-Chain Proof of Progress

### ✅ Real Private Deposit
- **Amount**: 4 BGT
- **Transaction**: [View on Snowtrace](https://testnet.snowtrace.io/tx/0xd5bd6e6c33ba6456d386230e4820982bba69674640e1103d6416de20ef1a95a2)
- **Action**: `approve()` → `deposit()` to `EncryptedERC`
- **Proof**: This shows real integration with eERC20

### ✅ On-Chain Proposal
- **Description**: "Increase Q3 Marketing Budget by 50 BGT"
- **Transaction**: [View on Snowtrace](https://testnet.snowtrace.io/tx/0x4e126e83f6421107fb2efad22c48f2e3461295dcc4c3e6b4e9f5c5bd7faec8c8)
- **Start Time**: Sep 5, 2025 @ 10:10 AM UTC
- **End Time**: Sep 10, 2025 @ 10:10 AM UTC

---

## 🚀 Frontend

Run locally:
```bash
cd frontend
npm install
npm run dev


🎯 Roadmap
Milestone 1:
MVP Prototype ✅ Done (Aug 23)
Deployed GovToken, EncryptedERC, Registrar, and verifiers on Fuji
Auditor registration with real zk-SNARK proof
Encrypted deposits tested and working
20+ passing tests for core functionality
Status: ✅ Done

Milestone 2:
ZK Governance ✅ Done (Sep 7)
Deployed GovernorZK contract with ZK voting and encrypted budget proposals
Used EncryptedERC (converter mode) for private voting power
Built React dApp with real on-chain proposals
Integrated with eERC20 (EncryptedERC) for private token deposits
- Executed real private deposit: 4 BGT → EncryptedERC (Fuji)
- Built interactive React frontend with MetaMask integration
Simulated private voting with ZK eligibility
Timeline: August 25 – September 7, 2025
Status: ✅ Done



Milestone 3: dApp Frontend + Full ZK Integration
  - Build React-based dApp for private governance  
  - Enable private proposal creation, voting, and balance decryption  
  - Connect to Avalanche C-Chain  
  - Develop custom Circom circuit for anonymous voting  
  - Enable client-side proof generation for voting and transfers  
  - Integrate with EncryptedERC SDK  
  - Timeline: September 7–14, 2025  
  - Dependencies: ethers.js, EncryptedERC SDK  
  - Status: 🟡 In Progress  


Milestone 4: Audit & Mainnet 
Conduct security audit
Run beta tests with early adopters
Deploy to Avalanche C-Chain mainnet
Onboard first DAOs and corporate boards
Timeline: Post-hackathon (September 2025 onward)
Dependencies: Funding, Codebase Accelerator
Status: ⚪ Planned


📢 Go-to-Market Strategy
We're taking an app-first approach, starting with DAOs as our entry market:

High-stakes treasury votes
Sensitive proposal decisions
Need for private governance
Adoption path:

1. DAOs → 2. Web3 Funds → 3. Corporate Boards
We keep the architecture flexible so it can be used as a privacy layer in the future.

