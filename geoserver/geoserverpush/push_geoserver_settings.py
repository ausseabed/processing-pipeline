#!/usr/bin/python3
"""
This script is used to register GeoTiffs into a geoserver instance
Requires environmental variables GEOSERVER_URL, GEOSERVER_ADMIN_PASSWORD and LIST_PATH

Example:
export GEOSERVER_URL="http://localhost:8080/geoserver"
export GEOSERVER_ADMIN_PASSWORD="###"
export LIST_PATH="https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
./push_geoserver_settings.py

Todo: 
    * move from json file into PostGres Database
    * provide path for non-public users
    * shift environmental variables to command line strings (requires work in step functions)
    * write some unit tests and add documentation
    * inputs come from a trusted source - nevertheless ensure that they are all properly escaped
"""

import os
import sys

from connection_parameters import ConnectionParameters
from product_database import ProductDatabase
from geoserver_catalog_services import GeoserverCatalogServices
from geoserver_raster import GeoserverRaster
# SET GEOSERVER_URL

def populate_geoserver():
    """ From environment variables, register layers with geoserver instance
    """
    settings = ConnectionParameters()
    settings.load_from_commandline()
    product_database = ProductDatabase()
    product_database.load_from_commandline()
    geoserver_catalog_services = GeoserverCatalogServices(settings)
    geoserver_catalog_services.add_styles()

    # Import rasters into geoserver for each entry in database
    for source_tif_entry in product_database.get_records():
        geoserver_bath_raster = GeoserverRaster()
        geoserver_bath_raster.load_bath_from_database_entry(source_tif_entry)
        geoserver_bath_raster_ref = geoserver_catalog_services.add_raster(geoserver_bath_raster)
        geoserver_catalog_services.add_style_to_raster(geoserver_bath_raster_ref["name"],
                                                       geoserver_catalog_services.BATH_STYLE_NAME)

        geoserver_hs_raster = GeoserverRaster()
        geoserver_hs_raster.load_hillshade_from_database_entry(source_tif_entry)
        if geoserver_hs_raster.source_tif!="":
            geoserver_hs_raster_ref = geoserver_catalog_services.add_raster(geoserver_hs_raster)
            geoserver_catalog_services.add_style_to_raster(geoserver_hs_raster_ref["name"],
                                                       geoserver_catalog_services.BATH_HILLSHADE_STYLE_NAME)
            geoserver_catalog_services.group_layers(
                [geoserver_hs_raster,geoserver_bath_raster],
                [geoserver_catalog_services.BATH_HILLSHADE_STYLE_NAME,geoserver_catalog_services.BATH_STYLE_NAME],
                geoserver_hs_raster_ref["bbox"]
                )



if __name__ == '__main__':
    populate_geoserver()

