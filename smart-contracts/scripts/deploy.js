const hre = require("hardhat");

async function main() {
  // Get contract factory
  const CharityPlatform = await hre.ethers.getContractFactory(
    "CharityPlatform"
  );

  // Deploy contract
  const charity = await CharityPlatform.deploy();

  console.log(charity.target);

  // Log the contract deployment address
  console.log("Deploying contract to:", charity.target);

  // Wait for the contract deployment transaction to be mined
  const tx = await charity.deploymentTransaction().wait(1);
  //   console.log(tx);

  // Log the transaction hash
  console.log("Contract deployed! Transaction hash:", tx.hash);

  // Log the contract address
  console.log("Contract deployed at address:", charity.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
