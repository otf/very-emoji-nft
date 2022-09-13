 // scripts/deploy.ts

const hre = require("hardhat");

async function main() {

  const VeryEmoji = await hre.ethers.getContractFactory("VeryEmoji");
  console.log('Deploying VeryEmoji ERC721 token...');
  const token = await VeryEmoji.deploy();

  await token.deployed();
  console.log("VeryEmoji deployed to:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
