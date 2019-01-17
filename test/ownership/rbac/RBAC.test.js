var RBAC = artifacts.require("./ownership/rbac/RBAC.sol");

contract("RBAC", function(accounts) {
  var RBACInstance;

////////////modifiers not tested

/////////if this test passes, the require stattements were satisfied
  it("initializes msg.sender with correct roles, tests check Role", function() {
      return RBAC.deployed().then(function(instance) {
        RBACInstance = instance;
        return RBACInstance.checkRole(accounts[0], "admin");
      }).then(function(checkRole) {
        assert.equal(checkRole, checkRole);
        return RBACInstance.checkRole(accounts[0], "partner");
      }).then(function(checkRole) {
        assert.equal(checkRole, checkRole);
      });
    });

    it("tests hasRole", function() {
        return RBAC.deployed().then(function(instance) {
          RBACInstance = instance;
          return RBACInstance.hasRole(accounts[0], "admin");
        }).then(function(checkRole) {
          assert.equal(checkRole, true);
          return RBACInstance.hasRole(accounts[0], "partner");
        }).then(function(checkRole) {
          assert.equal(checkRole, true);

        return RBACInstance.hasRole(accounts[0], "ner");
      }).then(function(checkRole) {
        assert.equal(checkRole, false);
      });
      });


      it("tests adminAddRole", function() {
          return RBAC.deployed().then(function(instance) {
            RBACInstance = instance;
            RBACInstance.adminAddRole(accounts[1], "newrole")
            return RBACInstance.hasRole(accounts[1], "newrole");
          }).then(function(hasRole) {
            assert.equal(hasRole, true);
        });
        });

        it("tests removeRole", function() {
            return RBAC.deployed().then(function(instance) {
              RBACInstance = instance;
              RBACInstance.adminRemoveRole(accounts[1], "newrole")
              return RBACInstance.hasRole(accounts[1], "newrole");
            }).then(function(hasRole) {
              assert.equal(hasRole, false);
          });
          });

});
