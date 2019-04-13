var Migrations = artifacts.require("./Migrations.sol");
var Test = artifacts.require("./Test.sol");
//var CCGX = artifacts.require("./ccgx.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Test);
  //deployer.deploy(CCGX);
};
