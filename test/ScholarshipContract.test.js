var Scholarship = artifacts.require("./ScholarshipContract.sol");

contract("ScholarshipContract", function(accounts) {
  var ScholarshipInstance;


  it("tests getWalletAddress", function() {
      return Scholarship.deployed().then(function(instance)  {
        ScholarshipInstance = instance;

        //run the create function
        ScholarshipInstance.create("1", accounts[0], "type", "title", "descript", 1, 20, ScholarshipInstance.address, ["allow", "collection"]);

        return ScholarshipInstance.getWalletAddress("1");
      }).then(function(getWalletAddress) {
        assert.equal(getWalletAddress, ScholarshipInstance.address);
      });
    });

    xit('tests join', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return Scholarship.address;
      }).then(function(address) {
        assert.equal();
      });
    });

    xit('tests addCollection', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return Scholarship.address;
      }).then(function(address) {
        assert.equal();
      });
    });

    xit('tests addQuestion', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return scholarship.address;
      }).then(function(address) {
        assert.equal();
      });
    });

    xit('tests getAllowedCollection', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getAllowedCollection("1", "1");
      }).then(function(getAllowedQuestion) {
        assert.equal(getAllowedCollection, 1);
      });
    });

    xit('tests getAllowedQuestion', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getAllowedQuestion("1", "1");
      }).then(function(getAllowedQuestion) {
        assert.equal(getAllowedCollection, 1);
      });
    });

    xit('tests getAllowedCollection', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getAllowedCollection("1", "1");
      }).then(function(getAllowedQuestion) {
        assert.equal(getAllowedCollection, 1);
      });
    });

    xit('tests drop', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getAllowedCollection("1", "1");
      }).then(function(getAllowedQuestion) {
        assert.equal(getAllowedCollection, 1);
      });
    });

    xit('tests getScholarshipData', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getScholarshipData("1");
      }).then(function(getScholarshipData) {
        assert.equal(getScholarshipData, [
        "0x7469746c65000000000000000000000000000000000000000000000000000000",
        "0x7479706500000000000000000000000000000000000000000000000000000000",
        "0x6465736372697074000000000000000000000000000000000000000000000000",
        "0xc1e87184627fb95a78b13c99f5da1d1143990478",
        "0xf3f854ae44d1026ea01d510c2f55236d3234b9e4",
        {"c": [1547686463],
         "e": 9,
          "s": 1
        }
       ]);
      });
    });

    it('tests getTimestamp', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;

        return ScholarshipInstance.getTimestamp("1");
      }).then(function(getTimestamp) {
        assert.equal(getTimestamp.toNumber(), getTimestamp.toNumber());
      });
    });


    //0 participants
    it('tests getParticipant', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getParticipant("1", accounts[0]);
      }).then(function(getParticipant) {
        assert.equal(getParticipant.toNumber(), 0);
      });
    });

    it('tests getType', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.getType("1");
      }).then(function(getType) {
        assert.equal(getType, 0x7479706500000000000000000000000000000000000000000000000000000000);
      });
    });

    //balance of 0
    it('tests balanceOf', function() {
      return Scholarship.deployed().then(function(instance) {
        ScholarshipInstance = instance;
        return ScholarshipInstance.balanceOf("1");
      }).then(function(balanceOf) {
        assert.equal(balanceOf.toNumber(), 0);
      });
    });

});
