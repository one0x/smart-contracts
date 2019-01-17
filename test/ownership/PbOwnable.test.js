var PbOwnable = artifacts.require("./ownership/PbOwnable.sol");

contract("PbOwnable", function(accounts) {
  var PbOwnableInstance;

  //account 0 deploys
  it('initializes the contract with the correct owner value', function() {
    return PbOwnable.deployed().then(function(instance) {
      PbOwnableInstance = instance;
      return PbOwnableInstance.owner();
    }).then(function(address) {
      assert.equal(address, accounts[0]);
    });
  });

  //accountt 1 transfer ownership
  it('tests ttransferownership', function() {
    return PbOwnable.deployed().then(function(instance) {
      PbOwnableInstance = instance;
      PbOwnableInstance.transferOwnership(accounts[1]);
      return PbOwnableInstance.owner();
    }).then(function(PbOwnableInstance) {
      assert.equal(PbOwnableInstance, accounts[1]);
    });
  });


});
