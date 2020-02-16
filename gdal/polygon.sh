#!/bin/sh
echo Starting script
env

# test with export AWS_NO_SIGN_REQUEST=YES

# test with s3://bathymetry-survey-288871573946/TestObject.tif
echo Starting translate of "$S3_SRC_TIF"
VSIS3=`echo "$S3_SRC_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME=`echo "$VSIS3" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR=`echo "$S3_SRC_TIF" | sed "s/\/[^\/]\+$/\//"`

echo resulting variable VSIS3="$VSIS3"
echo resulting variable LOCALNAME="$LOCALNAME"
echo resulting variable S3DIR="$S3DIR"

gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 "$VSIS3" "$LOCALNAME".tif 
#gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946/TestObject.tif output.tif 
echo Starting Polygonise
/usr/bin/gdal_polygonize.py "$LOCALNAME".tif "$LOCALNAME".shp
echo AWS commit
/usr/local/bin/aws2 s3 cp . "$S3DIR" --recursive --include "$LOCALNAME*"  --exclude "*" 
