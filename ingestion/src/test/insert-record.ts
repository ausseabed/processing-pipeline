import { ProductEntry } from '../entity/product-entry';

import { addExampleObject } from "../addExampleObject";

var assert = require('assert');

describe('Array', function () {
  describe('#indexOf()', function () {
    it('should return -1 when the value is not present', function () {
      assert.equal([1, 2, 3].indexOf(4), -1);
    });
  });
});



assert.doesNotThrow(addExampleObject)
var productEntry = addExampleObject();
//saveRecord(productEntry);

// const allUsers = await repository.find();
// const firstUser = await repository.findOne(1); // find by id
// const timber = await repository.findOne({ firstName: "Timber", lastName: "Saw" });

// await repository.remove(timber);