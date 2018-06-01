const Web3 = require('web3');

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  web3: Web3,
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // Match any network id
      gas: 6712388,
      gasPrice: 65000000000,
    },
    // Local Parity Development 
    dev: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      from: "",
      gas: 6725527,
    }
  },
};