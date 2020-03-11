import sys,os
import requests
from geoserver_raster import GeoserverRaster
from xml.sax.saxutils import escape

class ProductRecord():
    """ 
    Product Record data structure (at the moment a json formatted file that has the form:
 [
  {"filename": "s3://bucket-name/name-of-file.tif",
  "hillshade": "s3://bucket-name/name-of-file.tif",
  "l0-coverage": "s3://bucket-name/name-of-file.shp"
  "gazeteer-name":"e.g. Beagle Commonwealth Marine Reserve",
  "srs":"EPSG:32755",
  "year":2018,
  "resolution":"1m",
  "UUID":"68f44afd-78d0-412f-bf9c-9c9fdbe43968"}, ...
    """
    def __init__(self, input_dictionary):
        self.filename=input_dictionary["filename"]
        self.hillshade=input_dictionary["hillshade"]
        self.l0_coverage=input_dictionary["l0-coverage"]
        self.gazeteer_name=input_dictionary["gazeteer-name"]
        self.year=input_dictionary["year"]
        self.resolution=input_dictionary["resolution"]
        self.UUID=input_dictionary["UUID"]
        self.srs=input_dictionary["srs"]

    def get_bathymetric_raster(self):
        geoserver_bath_raster = GeoserverRaster()
        geoserver_bath_raster.load_bath_from_database_entry(self)
        return geoserver_bath_raster 

    def get_hillshade_raster(self):
        geoserver_bath_raster = GeoserverRaster()
        geoserver_bath_raster.load_hillshade_from_database_entry(self)
        return geoserver_bath_raster 

    def get_l0_coverage_name(self):
        return("{0} {1} {2} L0 Coverage".format(
            self.gazeteer_name, self.year, self.resolution))

    def get_l0_coverage(self):
        return self.l0_coverage
