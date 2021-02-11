module.exports = {
  // Configure networks
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
    },
  },
  // Configure MochaJS testing framework
  mocha: {
    // timeout: 100000
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: 'native',
    },
  },
}

