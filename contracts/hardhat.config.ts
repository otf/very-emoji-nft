import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter"
import * as dotenv from "dotenv"

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.9",

  networks: {
    mumbai: {
      url: process.env.API_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};

export default config;
