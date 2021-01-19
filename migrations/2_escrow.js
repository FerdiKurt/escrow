const Escrow = artifacts.require("EscrowContract");

module.exports = function(deployer, _network, accounts) {
  deployer.deploy(Escrow);
};
