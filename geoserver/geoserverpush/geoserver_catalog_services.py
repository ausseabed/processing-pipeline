
from geoserver.catalog import Catalog
from geoserver.catalog import UnsavedCoverageStore
from xml.sax.saxutils import escape
import requests
from requests.auth import HTTPBasicAuth

class GeoserverCatalogServices:
    """ 
    Geoserver Catalog Services provides a wrapper around the geoserver.catalogue 
    library. The functions allow for adding of rasters and styles
    """
    def __init__(self,connection_parameters):
        self.connection_parameters = connection_parameters
        self.BATH_STYLE_NAME = "Bathymetry"
        self.BATH_HILLSHADE_STYLE_NAME = "BathymetryHillshade"
        self.LOCAL_STYLE_FILENAME = "/usr/local/pulldata/bathymetry_transparent.sld"
        self.BATH_HILLSHADE_STYLE_FILENAME = "/usr/local/pulldata/bathymetry_hillshade.sld"
        self.WORKSPACE_NAME="ausseabed"
        self.cat = Catalog(self.connection_parameters.geoserver_url + "/rest", "admin",
                           self.connection_parameters.geoserver_password)
        self.ws = self.cat.create_workspace(self.WORKSPACE_NAME, self.connection_parameters.geoserver_url + '/'+self.WORKSPACE_NAME)

    def add_styles(self):
        """ Add the bathymetry styles used in the marine portal
        """
        bathymetry_transparent_file = open(self.LOCAL_STYLE_FILENAME)
        self.cat.create_style(self.BATH_STYLE_NAME, bathymetry_transparent_file, False, workspace=self.ws.name)

        bathymetry_hillshade_file = open(self.BATH_HILLSHADE_STYLE_FILENAME)
        self.cat.create_style(self.BATH_HILLSHADE_STYLE_NAME, bathymetry_hillshade_file, False, workspace=self.ws.name)

    def add_style_to_raster(self, raster_name, style_name):
        print ("Connecting {0} to {1}".format(raster_name,style_name))
        layer = self.cat.get_layer(raster_name)
        layer.default_style = style_name
        resp = self.cat.save(layer)
        if resp.status_code != 201 and resp.status_code != 200:
            print("Error {} processing: {}".format(resp, raster_name))
            print(resp.text)
            print(resp.reason)
        else:
            print("Successfully assigned bathymetry style")

    def group_layers(self, layers, styles,bbox):
        #my_bounds=("433248.5", "5662267.5", "455227.5", "5677920.5", "EPSG:28355")
        print (bbox)
        unsaved_layer_group=self.cat.create_layergroup(layers[0].base_name,
            title=layers[0].base_name, workspace=self.ws.name, bounds=bbox)
        
        unsaved_layer_group.layers = [self.lookup_layer_fqn(layer) for layer in layers]
        #unsaved_layer_group.styles = [self.lookup_style_fqn(style) for style in styles]
        
        self.cat.save(unsaved_layer_group)

    #def get_layer_bounds(self, layer_name):
    #    layer = self.cat.get_layer(layer_name)
    #    return layer.

    def lookup_layer_fqn(self, layer):
        return "{0}:{1}".format(self.ws.name, layer.display_name)

    def lookup_style_fqn(self, style_name):
        return self.cat.get_style(style_name,workspace=self.ws.name).fqn

    def add_raster_from_names(self, source_tif, native_layer_name, display_name, uuid, srs):
        # The normal import coverage only supports a few types (not S3GeoTiff), so
        # we have copied out the code here

        unsavedCoverage = UnsavedCoverageStore(self.cat, escape(uuid), self.ws.name)
        unsavedCoverage.type = "S3GeoTiff"

        # NOTE for non-public services, we will have some work to do here
        unsavedCoverage.url = source_tif + "?useAnon=true&awsRegion=AP_SOUTHEAST_2"  # ap-southeast-2

        resp = self.cat.save(unsavedCoverage)
        if resp.status_code != 201:
            print("Error {} processing: {}".format(resp, source_tif))
            print(resp.text)
            print(resp.reason)
        else:
            print("From filename {}, created unsaved coverage name {}".format(native_layer_name, unsavedCoverage.name))

        print("Attempting to create layer with name: {}".format(display_name))
        data = "<coverage><name>{}</name><title>{}</title><nativeName>{}</nativeName><srs>{}</srs></coverage>".format(
            display_name, display_name, native_layer_name, srs)
        url = "{}/workspaces/{}/coveragestores/{}/coverages.xml".format(self.cat.service_url, self.ws.name,
                                                                        unsavedCoverage.name)
        headers = {"Content-type": "application/xml"}

        resp = self.cat.http_request(url, method='post', data=data, headers=headers)
        if resp.status_code != 201:
            print("Error {} processing: {}".format(resp, source_tif))
            print(resp.text)
            print(resp.reason)
            return ""

        print("Successfully created")

        # Get information about the newly created coverage
        url = "{}/workspaces/{}/coverages/{}".format(self.cat.service_url, self.ws.name,
                                                                        display_name)
        response = requests.get(url, 
            auth=self.connection_parameters.get_auth(),
            headers={"Accept": "application/json"}
            )
        if not response.ok:
            print("Could not find coverage {}".format(display_name))
            print(response.content)
            return ""

        resp = response.json()
        bbox=resp["coverage"]["nativeBoundingBox"]
        srs=resp["coverage"]["srs"]

        # want form ("433248.5", "5662267.5", "455227.5", "5677920.5", "EPSG:28355")
        # have form {u'minx': 146.82151735057383, u'miny': -39.47860797949455, u'maxx': 147.48124691203017, u'maxy': -39.223417842248914, u'crs': u'EPSG:4326'}
        bbox_output=(bbox[u'minx'],bbox[u'maxx'],bbox[u'miny'],bbox[u'maxy'],srs)
        print (bbox_output)

        return {"name":display_name, "bbox":bbox_output}

    def add_raster(self, raster):
        return self.add_raster_from_names(raster.source_tif, raster.native_layer_name, raster.display_name,
                               raster.uuid, raster.srs)
