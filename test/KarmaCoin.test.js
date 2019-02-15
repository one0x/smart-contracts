var KarmaCoin = artifacts.require("./KarmaCoin.sol");

contract("KarmaCoin", function(accounts) {
	var KarmaInstance;
	
	it("initializes contract with correct values", function() {
		return KarmaCoin.deployed().then(function(instance) {
			KarmaInstance = instance;
			return KarmaInstance.name();
		}).then(function(name) {
			assert.equal(name, "KARMA KNOWLEDGE COIN");
			return KarmaInstance.symbol();
		}).then(function(symbol) {
			assert.equal(symbol, "KKC");
			return KarmaInstance.decimals();
		}).then(function(decimals) {
			assert.equal(decimals, 18);
		});
	});
	
	xit("tests mintFor", function() {
		return KarmaCoin.deployed().then(function(instance) {
			KarmaInstance = instance;
			KarmaInstance.mintFor(accounts[0], 100);
			return KarmaInstance.totalSupply_;
		}).then(function(totalSupply_) {
			assert.equal(totalSupply_.toNumber(), 1000);
			
		});
	});
	
	xit("tests burnFrom", function() {
		return KarmaCoin.deployed().then(function(instance) {
			KarmaInstance = instance;
			KarmaInstance.mintFor(accounts[0], 100);
			return KarmaInstance.totalSupply_;
		}).then(function(totalSupply_) {
			assert.equal(totalSupply_.toNumber(), 1000);
			
		});
	});
});
