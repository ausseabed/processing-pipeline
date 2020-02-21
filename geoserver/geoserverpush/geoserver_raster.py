from xml.sax.saxutils import escape
import re

class GeoserverRaster:
    """ The Geoserver Raster is a helper class for determining the names and attributes of the raster	"""
    def __init__(self):
        self.source_tif = self.base_name = self.display_name = self.native_layer_name = self.uuid = self.srs = ""


    def load_bath_from_database_entry(self, source_tif_entry):
        self.source_tif = source_tif_entry["filename"]
        self.base_name = escape("{0} {1} {2}".format(
            source_tif_entry["gazeteer-name"], source_tif_entry["year"], source_tif_entry["resolution"]))
        self.display_name = self.base_name + " OV"
        self.native_layer_name = re.sub(".tif", "", re.sub(".*/", "", self.source_tif))
        self.uuid = "{0}-OV".format(source_tif_entry["UUID"])
        self.srs = source_tif_entry["srs"]

    def load_hillshade_from_database_entry(self, source_tif_entry):
        self.source_tif = source_tif_entry["hillshade"]
        self.base_name = escape("{0} {1} {2}".format(
            source_tif_entry["gazeteer-name"], source_tif_entry["year"], source_tif_entry["resolution"]))
        self.display_name = self.base_name + " HS"
        self.native_layer_name = re.sub(".tif", "", re.sub(".*/", "", self.source_tif))
        self.uuid = "{0}-HS".format(source_tif_entry["UUID"])
        self.srs = source_tif_entry["srs"]

    def __str__(self):
        return "Registering: {0} with name: {1} and id: {2}".format(self.source_tif, self.display_name, self.uuid)