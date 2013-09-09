var mljs = require("../../mljs"),
    tests = exports,
    configurator = require('../../testconfig'),
    assert = require('assert'),
    winston = require('winston');

var logger = new (winston.Logger)({
  transports: [
    new winston.transports.File({ filename: 'logs/006-directory.log' })
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: 'logs/006-directory.log' })
  ]
});

describe("006-directory",function() {
  it("Should complete entirely",function(done){
  var db = new mljs(); // default options
  configurator.configure(db);
  db.setLogger(logger);
  
  // add three docs to the collection
  var col = {collection: "testcol"};
  var uris = ["/collections/1","/collections/2","/collections/3"];
  db.save({name:"first"},uris[0],col,function(result) {
    assert(!result.inError,"Error saving doc 1");
    db.save({name:"second"},uris[1],col,function(result) {
      assert(!result.inError,"Error saving doc 2");
      db.save({name:"third"},uris[2],col,function(result) {
        assert(!result.inError,"Error saving doc 3");
        
        logger.debug("TEST: list() Third save complete. Results object: " + JSON.stringify(result));
        // get docs in collection
        db.list("/collections",function(result) {
          // ensure there are 3
          logger.debug("TEST: list() collect results object: " + JSON.stringify(result));
          if (undefined == result.doc) {
            callback(false);
          } else {
            var isThree = (3==result.doc.total);
            assert(isThree,"There should only be three documents in " + col.collection);
          
            if (isThree){
              // now remove docs in collection
              db.delete(uris[0],function(result) {
                assert(!result.inError,"Error deleting doc 1");
                db.delete(uris[1],function(result) {
                  assert(!result.inError,"Error deleting doc 2");
                  db.delete(uris[2],function(result) {
                    assert(!result.inError,"Error deleting doc 3");
                    logger.debug("TEST: list() returning true for success");
                    done();
                  });
                });
              });
            }
          }
        });
      });
    });
  });
});});