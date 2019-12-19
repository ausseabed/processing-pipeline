
# Register a list of S3 GeoTiffs into a geoserver instance
# Requires GEOSERVER URL
# Path to a file listing the location of all the TIFFs

from geoserver.catalog import Catalog
from geoserver.catalog import UnsavedCoverageStore
from geoserver.catalog import build_url
from urllib.request import urlopen
import os
import sys
import re
import json

# SET GEOSERVER_URL="http://ec2-54-153-228-148.ap-southeast-2.compute.amazonaws.com/geoserver"
geoserver_url="http://ec2-54-153-228-148.ap-southeast-2.compute.amazonaws.com/geoserver"

try:  
   geoserver_url=os.environ['GEOSERVER_URL']
except KeyError: 
   print("Please set the environment variable GEOSERVER_URL")
   #sys.exit(1)

print("GEOSERVER_URL = " + geoserver_url)
geoserver_password="losable_password"

try:  
   geoserver_password=os.environ['GEOSERVER_ADMIN_PASSWORD']
except KeyError: 
   print("Please set the environment variable GEOSERVER_ADMIN_PASSWORD")
   #sys.exit(1)

source_tif_path="https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
try:  
   source_tif_path=os.environ['LIST_PATH']
except KeyError: 
   print("Please set the environment variable LIST_PATH")
   #sys.exit(1)

print("LIST_PATH = " + source_tif_path)

# Step 1 - read in a list of source tifs
f = urlopen(source_tif_path)
myfile = f.read()
source_tifs = json.loads(myfile)

#source_tifs= [{"filename":"s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_coloured.tif"}]

# Step 2 - push through RESTFUL interface
cat = Catalog(geoserver_url + "/rest", "admin", geoserver_password)
ws = cat.create_workspace('ausseabed',geoserver_url + '/ausseabed') 

for source_tif_entry in source_tifs:
   source_tif=source_tif_entry["filename"]
   print ("Registering: " + source_tif)

   # The normal import coverage only supports a few types (not S3GeoTiff), so 
   # we have copied out the code here
   unsavedCoverage = UnsavedCoverageStore(cat, "test",ws.name)
   unsavedCoverage.type="S3GeoTiff"

   # NOTE for non-public services, we will have some work to do here
   unsavedCoverage.url= source_tif + "?useAnon=true&awsRegion=ap-southeast-2"
   response = cat.save(unsavedCoverage)

   layer_name =re.sub(".tif","",re.sub(".*/","",source_tif))
   source_name = layer_name
   print("Coverage name (and native name) = " + layer_name)
   data = "<coverage><name>{}</name><nativeName>{}</nativeName></coverage>".format(layer_name, source_name)
   url = "{}/workspaces/{}/coveragestores/{}/coverages.xml".format(cat.service_url, ws.name, unsavedCoverage.name)
   headers = {"Content-type": "application/xml"}

   resp = cat.http_request(url, method='post', data=data, headers=headers)
   if resp.status_code != 201:
      print("Error {} processing: {}".format(resp,source_tif))

