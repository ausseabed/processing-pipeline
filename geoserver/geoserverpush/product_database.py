import sys,os
import requests
from product_record import ProductRecord

class ProductDatabase():
    """ 
    Product Database data structure (at the moment a json formatted file that has the form:
 [
  {"filename": "s3://bucket-name/name-of-file.tif",
  "hillshade": "s3://bucket-name/name-of-file.tif",
  "l0-coverage": "s3://bucket-name/name-of-file.shp"
  "gazeteer-name":"e.g. Beagle Commonwealth Marine Reserve",
  "year":2018,
  "resolution":"1m",
  "UUID":"68f44afd-78d0-412f-bf9c-9c9fdbe43968"}, ...
    """
    def load_from_commandline(self):
        try:
            self.source_tif_path = os.environ['LIST_PATH']
        except KeyError:
            print("Please set the environment variable LIST_PATH")
            sys.exit(1)

        print("Path to file that specifies what to load (LIST_PATH) = " + self.source_tif_path)

    def get_records(self):
        # Step 1 - read in a list of source tifs
        response = requests.get(self.source_tif_path)
        if not response.ok:
            print("Error trying to get LIST_PATH")

        self.source_tifs = response.json()

        print("Number of source_tifs: " + str(len(self.source_tifs)))

        results = [ProductRecord(x) for x in self.source_tifs]

        return results
