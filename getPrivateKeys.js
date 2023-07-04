const ethers = require('ethers');

const mnemonic = "test test test test test test test test test test test junk";  // replace with your mnemonic
const walletPath = "m/44'/60'/0'/0/";

for (let i = 0; i < 20; i++) {
  const wallet = ethers.Wallet.fromMnemonic(mnemonic, walletPath + i);
  console.log(`Account ${i}: ${wallet.privateKey}`);
}