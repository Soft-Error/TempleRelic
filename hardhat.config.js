// require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
// require("hardhat-gas-reporter");
// require("solidity-coverage");
// require('hardhat-contract-sizer');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// const ARBI_KEY = process.env.DEPLOYER_KEY;
const ETHERSCAN_API_KEY = "QNW2HXH4CT741NE21ETXMVDP6WYEWEMPGW";
const RINKEBY_KEY = "e710aaa09d060e9a70e06e3cea6876494f7fa0f13f5ba7008ad001fc58b9cfa1";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.4",
    defaultNetwork: "hardhat",
    optimizer: {
      enabled: true,
      runs: 200
    }
  }, 
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true
    },
    arbitrumRinkeby: {
      url: "https://rinkeby.arbitrum.io/rpc",
      accounts: [RINKEBY_KEY]
    },
    // arbitrum: {
    //   url: "https://arb1.arbitrum.io/rpc",
    //   accounts: [ARBI_KEY]
    // }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
 
};
