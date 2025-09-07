// src/App.tsx
import { useState, useEffect } from "react";
import { BrowserProvider, ethers } from "ethers";
import { motion as Motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

// Import ABIs
import GovernorZKABI from "./contracts/GovernorZK.json";
import EncryptedERCABI from "./contracts/EncryptedERC.json";
import GovTokenABI from "./contracts/GovToken.0.8.30.json"; 

function App() {
  const [account, setAccount] = useState("");
  const [loading, setLoading] = useState(false);
  const [voteSubmitted, setVoteSubmitted] = useState({});
  const [nullifiers, setNullifiers] = useState({});
  const [generatingProof, setGeneratingProof] = useState(false);
  const [proposalVotes, setProposalVotes] = useState({});
  const [proposals, setProposals] = useState([]);
  const [depositAmount, setDepositAmount] = useState("");

  // Contract addresses from .env
  const GOVERNOR_ZK_ADDRESS = import.meta.env.VITE_GOVERNOR_ZK_ADDRESS;
  const ENCRYPTED_ERC_ADDRESS = import.meta.env.VITE_ENCRYPTED_ERC_ADDRESS;
  const GOV_TOKEN_ADDRESS = import.meta.env.VITE_GOV_TOKEN_ADDRESS;

  const connectWallet = async () => {
    if (!window.ethereum) {
      alert("Please install MetaMask");
      return;
    }

    setLoading(true);
    try {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
      console.log("Wallet connected:", accounts[0]);

      if (GOVERNOR_ZK_ADDRESS) {
        await fetchProposals();
      }
    } catch (err) {
      console.error("Wallet connection error:", err);
      alert("Wallet connection failed. See console.");
    } finally {
      setLoading(false);
    }
  };

  const fetchProposals = async () => {
    try {
      const provider = new BrowserProvider(window.ethereum);
      const governor = new ethers.Contract(GOVERNOR_ZK_ADDRESS, GovernorZKABI.abi, provider);

      const filter = {
        address: GOVERNOR_ZK_ADDRESS,
        topics: [
          "0xe5e40c160f3b9a59e91b766f139aa9c1aea545e7be1debf5b377c9c1a88b9a79", // ProposalCreated
        ],
      };

      const logs = await provider.getLogs(filter);
      console.log("Fetched logs:", logs);

      if (logs.length === 0) {
        setProposals([
          {
            id: "0x071f0735e57c7c959f7eb7f7182f79d4d8726c920c7df7bc1624d8e30b13bc83",
            title: "Increase Q3 Marketing Budget by 50 BGT",
            description: "High-stakes proposal for DAO treasury allocation.",
            proposalId: "0x071f0735e57c7c959f7eb7f7182f79d4d8726c920c7df7bc1624d8e30b13bc83",
          },
        ]);
        return;
      }

      const fetchedProposals = logs.map((log) => {
        try {
          const parsed = governor.interface.parseLog(log);
          const args = parsed.args;
          return {
            id: args.proposalId,
            title: args.description,
            description: "On-chain proposal created via eERC20 governance",
            proposalId: args.proposalId,
          };
        } catch (err) {
          console.error("Failed to parse log:", err);
          return null;
        }
      }).filter(Boolean);

      setProposals(fetchedProposals);
    } catch (err) {
      console.error("Failed to fetch proposals:", err);
      setProposals([
        {
          id: "0x071f0735e57c7c959f7eb7f7182f79d4d8726c920c7df7bc1624d8e30b13bc83",
          title: "Increase Q3 Marketing Budget by 50 BGT",
          description: "High-stakes proposal for DAO treasury allocation.",
          proposalId: "0x071f0735e57c7c959f7eb7f7182f79d4d8726c920c7df7bc1624d8e30b13bc83",
        },
      ]);
    }
  };

  const voteAnonymously = async (proposalId, choice) => {
    if (!account) {
      alert("Wallet not connected");
      return;
    }

    if (voteSubmitted[proposalId]) {
      alert("You've already voted on this proposal!");
      return;
    }

    setGeneratingProof(true);

    // Simulate ZK proof generation
    await new Promise((res) => setTimeout(res, 2000));
    const simulatedNullifier = Math.random().toString(36).substring(2, 10);

    setVoteSubmitted((prev) => ({ ...prev, [proposalId]: choice }));
    setNullifiers((prev) => ({ ...prev, [proposalId]: simulatedNullifier }));
    setProposalVotes((prev) => ({
      ...prev,
      [proposalId]: {
        yes: (prev[proposalId]?.yes || 0) + (choice === "yes" ? 1 : 0),
        no: (prev[proposalId]?.no || 0) + (choice === "no" ? 1 : 0),
      },
    }));

    setGeneratingProof(false);
    alert("✅ Your vote has been submitted anonymously!");
  };

const approveAndDeposit = async () => {
  if (!account) {
    alert("Wallet not connected");
    return;
  }

  if (!depositAmount || isNaN(depositAmount) || parseFloat(depositAmount) <= 0) {
    alert("Enter a valid amount");
    return;
  }

  const provider = new BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  const govToken = new ethers.Contract(GOV_TOKEN_ADDRESS, GovTokenABI.abi, signer);
  const encryptedERC = new ethers.Contract(ENCRYPTED_ERC_ADDRESS, EncryptedERCABI.abi, signer);
  const amount = ethers.parseUnits(depositAmount, 18);

  setGeneratingProof(true);

  try {
    // Step 1: Approve
    const approvalTx = await govToken.approve(ENCRYPTED_ERC_ADDRESS, amount);
    alert(`✅ Approval sent: ${approvalTx.hash}`);
    await approvalTx.wait();

    // Step 2: Simulate PCT encryption (this is where ZK + ElGamal happens off-chain)
    await new Promise((res) => setTimeout(res, 2000));

    // Step 3: Mock PCT (7-element array)
    const mockAmountPCT = [
      "1133472187455040099476470318390842520877981045416610090496657020913474642700",
      "15138354140799140706805329862341112550267606198205775699128210634181363419367",
      "8278260157443619140440683489025089546727778464865134253075549758795429855259",
      "9292550731208796964159392307945247761339538359064622016194710231402257698902",
      "1227125635792104617078415376638316418341911877888640945374480192592835987224",
      "13496370187882181827025896117321717903662417763933092385338408030705744089780",
      "20627431652359793548045362803068920545658985469379204114013658895477985722882"
    ];

    // Step 4: Call deposit()
    const depositTx = await encryptedERC.deposit(
      amount,
      GOV_TOKEN_ADDRESS,
      mockAmountPCT
      // message is optional
    );

    setGeneratingProof(false);
    alert(`✅ Deposit transaction sent! Check Snowtrace: ${depositTx.hash}`);
  } catch (err) {
    console.error("Deposit failed:", err);
    setGeneratingProof(false);
    alert(`❌ Deposit failed: ${err.message || "Unknown error"}`);
  }
};

  const totalVotes = proposals.reduce(
    (acc, p) => {
      acc.yes += proposalVotes[p.id]?.yes || 0;
      acc.no += proposalVotes[p.id]?.no || 0;
      return acc;
    },
    { yes: 0, no: 0 }
  );

  return (
    <div className="h-screen w-screen flex overflow-hidden">
      {/* Left Section */}
      <div className="flex flex-col items-center justify-center w-1/3 bg-gradient-to-br from-gray-900 to-black text-white p-6">
        <Motion.div
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center space-y-4"
        >
          <h1 className="text-5xl font-extrabold tracking-tight bg-gradient-to-r from-cyan-400 to-blue-600 bg-clip-text text-transparent">
            BoardroomX
          </h1>
          <p className="text-lg text-gray-300">Privacy-Preserving Governance for DAOs & Boards</p>
        </Motion.div>

        <Motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="mt-10 w-full max-w-md"
        >
          <Card className="bg-gray-800/70 border border-gray-700 shadow-lg rounded-2xl">
            <CardContent className="p-6 flex flex-col items-center space-y-4">
              {account ? (
                <>
                  <p className="text-green-400 font-mono text-sm">
                    Connected: {account.slice(0, 6)}...{account.slice(-4)}
                  </p>
                  <Button
                    variant="outline"
                    className="bg-red-500/10 border-red-500 text-red-400 hover:bg-red-500 hover:text-white"
                    onClick={() => setAccount("")}
                  >
                    Disconnect
                  </Button>

                  <div className="mt-4 w-full flex flex-col space-y-3">
                    <input
                      type="number"
                      placeholder="Amount to deposit"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      className="w-full p-2 rounded-xl text-white bg-gray-700/50 placeholder-gray-300"
                    />
                    <Button
                      onClick={approveAndDeposit}
                      disabled={generatingProof}
                      className="w-full bg-gradient-to-r from-yellow-400 to-orange-500 text-black font-semibold py-2 px-4 rounded-xl shadow-lg hover:scale-105 transition-transform"
                    >
                      {generatingProof ? "⏳ Generating Proof..." : "🔐 Deposit Privately"}
                    </Button>
                  </div>
                </>
              ) : (
                <Button
                  onClick={connectWallet}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-semibold py-2 px-4 rounded-xl shadow-lg hover:scale-105 transition-transform"
                >
                  {loading ? "Connecting..." : "Connect Wallet"}
                </Button>
              )}
            </CardContent>
          </Card>
        </Motion.div>
      </div>

      {/* Right Section */}
      <div className="flex flex-col items-start justify-center w-2/3 bg-gradient-to-br from-cyan-800 to-gray-900 text-white p-8 overflow-y-auto">
        {account && (
          <div className="mb-6 bg-black/30 rounded-xl p-4 w-full text-gray-200">
            <h2 className="text-lg font-bold text-cyan-400 mb-2">Total Votes (All Proposals)</h2>
            <p>✅ Yes: {totalVotes.yes} | ❌ No: {totalVotes.no}</p>
          </div>
        )}

        <div className="w-full max-w-3xl space-y-8">
          {account ? (
            proposals.length > 0 ? (
              proposals.map((proposal) => (
                <Motion.div
                  key={proposal.proposalId || proposal.id}
                  initial={{ opacity: 0, x: 50 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.8 }}
                  className={`bg-black/40 backdrop-blur-sm border rounded-2xl p-6 ${voteSubmitted[proposal.proposalId || proposal.id] ? "border-green-400/50" : "border-cyan-500/30"}`}
                >
                  <h2 className="text-xl font-bold text-cyan-400 mb-2">{proposal.title}</h2>
                  <p className="text-gray-200 mb-4">{proposal.description}</p>

                  <div className="flex space-x-4">
                    <Button
                      onClick={() => voteAnonymously(proposal.proposalId || proposal.id, "yes")}
                      disabled={generatingProof || voteSubmitted[proposal.proposalId || proposal.id]}
                      className="bg-gradient-to-r from-green-500 to-emerald-600 hover:scale-105 transition-transform py-2 px-4 text-lg"
                    >
                      {generatingProof && !voteSubmitted[proposal.proposalId || proposal.id] ? "⏳ Voting..." : "✅ Yes"}
                    </Button>
                    <Button
                      onClick={() => voteAnonymously(proposal.proposalId || proposal.id, "no")}
                      disabled={generatingProof || voteSubmitted[proposal.proposalId || proposal.id]}
                      className="bg-gradient-to-r from-red-500 to-pink-600 hover:scale-105 transition-transform py-2 px-4 text-lg"
                    >
                      {generatingProof && !voteSubmitted[proposal.proposalId || proposal.id] ? "⏳ Voting..." : "❌ No"}
                    </Button>
                  </div>

                  {voteSubmitted[proposal.proposalId || proposal.id] && (
                    <p className="mt-2 text-purple-400 font-mono text-sm">
                      ✅ Your vote has been recorded (Anonymous ID: {nullifiers[proposal.proposalId || proposal.id]})
                    </p>
                  )}

                  {proposalVotes[proposal.proposalId || proposal.id] && (
                    <div className="mt-3 text-gray-200 text-sm">
                      ✅ Yes: {proposalVotes[proposal.proposalId || proposal.id].yes} | ❌ No: {proposalVotes[proposal.proposalId || proposal.id].no}
                    </div>
                  )}
                </Motion.div>
              ))
            ) : (
              <p className="text-gray-300">No proposals found. Check back later.</p>
            )
          ) : (
            <Motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
              className="text-center text-gray-300"
            >
              <h2 className="text-3xl font-bold text-cyan-400">Welcome to BoardroomX</h2>
              <p className="mt-4">Connect your wallet to access private governance, deposit tokens, and vote anonymously.</p>
            </Motion.div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;