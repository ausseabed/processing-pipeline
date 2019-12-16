#!/bin/sh
echo Starting translate
#gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_coloured.tif output.tif 
gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946/TestObject.tif output.tif 
echo Starting Polygonise
/usr/bin/gdal_polygonize.py output.tif output.shp 
echo AWS commit
/usr/local/bin/aws2 s3 cp . s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/ --recursive --include "output*"  --exclude "*" 
