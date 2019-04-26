var TimeLockedWalletFactory = artifacts.require("TimeLockedWalletFactory");
var CCGX = artifacts.require("./CCGX.sol");

module.exports = function(deployer) {
  deployer.deploy(TimeLockedWalletFactory);
  deployer.deploy(CCGX);
};
