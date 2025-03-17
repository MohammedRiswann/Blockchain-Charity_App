require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { ethers } = require("ethers");
const contractABI = require("./abi.json");

const app = express();
app.use(cors());
app.use(express.json());

// Connect to the local Hardhat network or any other network
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545"); // Ensure this matches your Hardhat network
const signer = provider.getSigner(); // Default signer (first account from Hardhat)
const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with your contract's deployed address
const contract = new ethers.Contract(contractAddress, contractABI, signer);

// POST route to register a recipient
app.post("/register-recipient", async (req, res) => {
  try {
    console.log("Received request:", req.body);
    const { userWallet, name, reason, amountNeeded } = req.body;

    if (!ethers.utils.isAddress(userWallet)) {
      return res.status(400).json({ error: "Invalid Ethereum address" });
    }

    // Use user's wallet address in the transaction
    const tx = await contract.registerRecipient(
      userWallet,
      name,
      reason,
      amountNeeded
    );
    await tx.wait();

    console.log("Transaction successful:", tx.hash);
    res.json({ success: true, txHash: tx.hash });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: error.message });
  }
});

// POST route to approve a recipient
app.post("/approve-recipient", async (req, res) => {
  try {
    const { recipientAddress } = req.body;
    const tx = await contract.approveRecipient(recipientAddress);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST route for donations
app.post("/donate", async (req, res) => {
  try {
    const { amount } = req.body;
    const tx = await contract.donate({
      value: ethers.utils.parseEther(amount),
    });
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST route to transfer funds
app.post("/transfer-funds", async (req, res) => {
  try {
    const { recipientAddress } = req.body;
    const tx = await contract.transferFunds(recipientAddress);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET route to fetch contract balance
app.get("/contract-balance", async (req, res) => {
  try {
    const balance = await contract.getContractBalance();
    res.json({ balance: ethers.utils.formatEther(balance) }); // Converts the balance to a readable format
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start the Express server
app.listen(5001, () => {
  console.log("Server running on port 5001");
});
