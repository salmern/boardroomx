import { useState } from "react";
import { motion as Motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

function App() {
  const [account, setAccount] = useState("");
  const [loading, setLoading] = useState(false);
  const [voteSubmitted, setVoteSubmitted] = useState({});
  const [nullifiers, setNullifiers] = useState({});
  const [generatingProof, setGeneratingProof] = useState(false);
  const [proposalVotes, setProposalVotes] = useState({});
  const [depositAmount, setDepositAmount] = useState("");

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
    } catch (err) {
      console.error("Wallet connection error:", err);
      alert("Wallet connection failed. See console.");
    } finally {
      setLoading(false);
    }
  };

  const proposals = [
    { id: 1, title: "DAO: Allocate 50 BGT to new development fund", description: "High-stakes proposal for DAO treasury allocation." },
    { id: 2, title: "Family Office: Approve private investment strategy", description: "Sensitive wealth decision to keep confidential." },
    { id: 3, title: "Corporate Board: Approve M&A transaction", description: "Decision to merge or acquire a company while keeping vote private." },
    { id: 4, title: "Regulated Fund: Confirm compliance report submission", description: "Prove compliance without leaking individual votes." },
  ];

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

    // Simulate proof generation delay
    await new Promise((res) => setTimeout(res, 2000));
    const simulatedNullifier = Math.random().toString(36).substring(2, 10);

    console.log("Simulated vote:", proposalId, choice);

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

  const depositTokens = () => {
    if (!account) {
      alert("Wallet not connected");
      return;
    }

    if (!depositAmount || isNaN(depositAmount)) {
      alert("Enter a valid amount");
      return;
    }

    setGeneratingProof(true);
    setTimeout(() => {
      alert(`✅ Deposit of ${depositAmount} ETH simulated successfully!`);
      setDepositAmount("");
      setGeneratingProof(false);
    }, 1500);
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
        <Motion.div initial={{ opacity: 0, y: -30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }} className="text-center space-y-4">
          <h1 className="text-5xl font-extrabold tracking-tight bg-gradient-to-r from-cyan-400 to-blue-600 bg-clip-text text-transparent">BoardroomX</h1>
          <p className="text-lg text-gray-300">Privacy-Preserving Governance for DAOs & Boards</p>
        </Motion.div>

        <Motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6, delay: 0.4 }} className="mt-10 w-full max-w-md">
          <Card className="bg-gray-800/70 border border-gray-700 shadow-lg rounded-2xl">
            <CardContent className="p-6 flex flex-col items-center space-y-4">
              {account ? (
                <>
                  <p className="text-green-400 font-mono text-sm">Connected: {account.slice(0, 6)}...{account.slice(-4)}</p>
                  <Button variant="outline" className="bg-red-500/10 border-red-500 text-red-400 hover:bg-red-500 hover:text-white" onClick={() => setAccount("")}>Disconnect</Button>

                  <div className="mt-4 w-full flex flex-col space-y-2">
                    <input
                      type="text"
                      placeholder="Amount to deposit (ETH)"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      className="w-full p-2 rounded-xl text-white bg-gray-700/50 placeholder-gray-300"
                    />
                    <Button onClick={depositTokens} disabled={generatingProof} className={`w-full bg-gradient-to-r from-yellow-400 to-orange-500 text-black font-semibold py-2 px-4 rounded-xl shadow-lg hover:scale-105 transition-transform ${generatingProof ? "opacity-50 cursor-not-allowed" : ""}`}>
                      {generatingProof ? "⏳ Generating Deposit Proof..." : "Deposit Tokens"}
                    </Button>
                  </div>
                </>
              ) : (
                <Button onClick={connectWallet} disabled={loading} className="w-full bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-semibold py-2 px-4 rounded-xl shadow-lg hover:scale-105 transition-transform">
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
            proposals.map((proposal) => (
              <Motion.div key={proposal.id} initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.8 }} className={`bg-black/40 backdrop-blur-sm border rounded-2xl p-6 ${voteSubmitted[proposal.id] ? "border-green-400/50" : "border-cyan-500/30"}`}>
                <h2 className="text-xl font-bold text-cyan-400 mb-2">{proposal.title}</h2>
                <p className="text-gray-200 mb-4">{proposal.description}</p>

                <div className="flex space-x-4">
                  <Button onClick={() => voteAnonymously(proposal.id, "yes")} disabled={generatingProof || voteSubmitted[proposal.id]} className="bg-gradient-to-r from-green-500 to-emerald-600 hover:scale-105 transition-transform py-2 px-4 text-lg">
                    {generatingProof && !voteSubmitted[proposal.id] ? "⏳ Voting..." : "✅ Yes"}
                  </Button>
                  <Button onClick={() => voteAnonymously(proposal.id, "no")} disabled={generatingProof || voteSubmitted[proposal.id]} className="bg-gradient-to-r from-red-500 to-pink-600 hover:scale-105 transition-transform py-2 px-4 text-lg">
                    {generatingProof && !voteSubmitted[proposal.id] ? "⏳ Voting..." : "❌ No"}
                  </Button>
                </div>

                {voteSubmitted[proposal.id] && (
                  <p className="mt-2 text-purple-400 font-mono text-sm">
                    ✅ Your vote has been recorded (Anonymous ID: {nullifiers[proposal.id]})
                  </p>
                )}

                {proposalVotes[proposal.id] && (
                  <div className="mt-3 text-gray-200 text-sm">
                    ✅ Yes: {proposalVotes[proposal.id].yes} | ❌ No: {proposalVotes[proposal.id].no}
                  </div>
                )}
              </Motion.div>
            ))
          ) : (
            <Motion.div initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.8 }} className="text-center text-gray-300">
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
