import { ProductEntry } from '../entity/product-entry';

var assert = require('assert');

describe('Array', function () {
  describe('#indexOf()', function () {
    it('should return -1 when the value is not present', function () {
      assert.equal([1, 2, 3].indexOf(4), -1);
    });
  });
});


function buildTestEntry() {
  const productEntry = new ProductEntry();
  productEntry.id = 1;
  productEntry.gazeteerName = "Beagle Commonwealth Marine Reserve";
  productEntry.year = "2018";
  productEntry.UUID = "GA-0364";
  productEntry.srs = "EPSG:32755";
  productEntry.l3ProductTifLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_Overlay.tif";
  productEntry.l0CoverageLocation = "s3://bathymetry-survey-288871573946/L0Coverage/coverage.shp";
  productEntry.l3CoverageLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m.shp";
  productEntry.hillshadeLocation = "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_HS.tif";
  return(productEntry);
}

function saveRecord(productEntry : ProductEntry)
{

  //await repository.save(productEntry);
}


assert.doesNotThrow(buildTestEntry)
var productEntry = buildTestEntry();
//saveRecord(productEntry);

// const allUsers = await repository.find();
// const firstUser = await repository.findOne(1); // find by id
// const timber = await repository.findOne({ firstName: "Timber", lastName: "Saw" });

// await repository.remove(timber);