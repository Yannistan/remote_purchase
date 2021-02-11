const { BN } = require('@openzeppelin/test-helpers');
const Boson = artifacts.require('Boson');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Boson, '0x5d5d0c110cA4107a86669B38fE461f45a9c6cDAC', '0x44F31c324702C418d3486174d2A200Df1b345376');
};
