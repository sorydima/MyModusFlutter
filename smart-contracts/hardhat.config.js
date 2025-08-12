require('@nomiclabs/hardhat-ethers');
module.exports = {
  solidity: '0.8.17',
  networks: {
    // configure via env or hardhat config later
    localhost: { url: 'http://127.0.0.1:8545' }
  }
};
