#!/usr/bin/python3
"""
This script is used to register GeoTiffs into a geoserver instance
Requires environmental variables GEOSERVER_URL, GEOSERVER_ADMIN_PASSWORD and LIST_PATH

LIST_PATH is a file that lists the location of all the TIFFs

The file has the form 
 [
  {"filename": "s3://bucket-name/name-of-file.tif",
  "gazeteer-name":"e.g. Beagle Commonwealth Marine Reserve",
  "year":2018,
  "resolution":"1m",
  "UUID":"68f44afd-78d0-412f-bf9c-9c9fdbe43968"}, ...

Example:
export GEOSERVER_URL="http://localhost:8080/geoserver"
export GEOSERVER_ADMIN_PASSWORD="###"
export LIST_PATH="https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
./push_geoserver_settings.py

Todo: 
   * move from json file into PostGres Database
   * provide path for non-public users
   * shift environmental variables to command line strings (requires work in step functions)
"""

from geoserver.catalog import Catalog
from geoserver.catalog import UnsavedCoverageStore
from geoserver.catalog import build_url
from xml.sax.saxutils import escape
from urllib.request import urlopen
from geoserver.support import ResourceInfo, xml_property, key_value_pairs, write_bool, write_dict, write_string, build_url
import os
import sys
import re
import json
import requests

# SET GEOSERVER_URL

try:  
   geoserver_url=os.environ['GEOSERVER_URL']
except KeyError: 
   print("Please set the environment variable GEOSERVER_URL")
   sys.exit(1)

print("GEOSERVER_URL = " + geoserver_url)

try:  
   geoserver_password=os.environ['GEOSERVER_ADMIN_PASSWORD']
except KeyError: 
   print("Please set the environment variable GEOSERVER_ADMIN_PASSWORD")
   sys.exit(1)

try:  
   source_tif_path=os.environ['LIST_PATH']
except KeyError: 
   print("Please set the environment variable LIST_PATH")
   sys.exit(1)

print("Path to file that specifies what to load (LIST_PATH) = " + source_tif_path)

# Step 1 - read in a list of source tifs
response = requests.get(source_tif_path)
if (not(response.ok)):
   print ("Error trying to get LIST_PATH")

source_tifs = response.json()

print ("Number of source_tifs: " + str(len(source_tifs)))

# Step 2 - push through RESTFUL interface
cat = Catalog(geoserver_url + "/rest", "admin", geoserver_password)
ws = cat.create_workspace('ausseabed',geoserver_url + '/ausseabed') 

for source_tif_entry in source_tifs:
   source_tif=source_tif_entry["filename"]
   print ("Registering: " + source_tif)
   display_name=escape("{0} {1} {2}".format(source_tif_entry["gazeteer-name"],source_tif_entry["year"],source_tif_entry["resolution"]))
   print ("With name: " + display_name)
   print ("And Id: " + escape(source_tif_entry["UUID"]))

   native_layer_name =re.sub(".tif","",re.sub(".*/","",source_tif))
   # The normal import coverage only supports a few types (not S3GeoTiff), so 
   # we have copied out the code here
   unsavedCoverage = UnsavedCoverageStore(cat, escape(source_tif_entry["UUID"]),ws.name)
   unsavedCoverage.type="S3GeoTiff"

   # NOTE for non-public services, we will have some work to do here
   unsavedCoverage.url= source_tif + "?useAnon=true&awsRegion=AP_SOUTHEAST_2" #ap-southeast-2
   #unsavedCoverage.dirty["srs"]=escape(source_tif_entry["srs"])
   #unsavedCoverage.writers["srs"]=write_string("srs")
   resp = cat.save(unsavedCoverage)
   if resp.status_code != 201:
      print("Error {} processing: {}".format(resp,source_tif))
      print(resp.text)
      print(resp.reason)
   else:
      print("From filename {}, created unsaved coverage name {}".format(native_layer_name,unsavedCoverage.name))

   print ("Attempting to create layer with name: {}".format(display_name))
   data = "<coverage><name>{}</name><nativeName>{}</nativeName><srs>{}</srs></coverage>".format(display_name, native_layer_name,source_tif_entry["srs"])
   url = "{}/workspaces/{}/coveragestores/{}/coverages.xml".format(cat.service_url, ws.name, unsavedCoverage.name)
   headers = {"Content-type": "application/xml"}

   resp = cat.http_request(url, method='post', data=data, headers=headers)
   if resp.status_code != 201:
      print("Error {} processing: {}".format(resp,source_tif))
      print(resp.text)
      print(resp.reason)
   else:
      print ("Successfully created")

