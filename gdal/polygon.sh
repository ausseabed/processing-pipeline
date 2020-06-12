#!/bin/sh
echo Starting script
env

# test with export AWS_NO_SIGN_REQUEST=YES

# test with s3://bathymetry-survey-288871573946/TestObject.tif
echo Starting translate of "$S3_SRC_TIF"
VSIS3_SRC=`echo "$S3_SRC_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME=`echo "$VSIS3_SRC" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR=`echo "$S3_SRC_TIF" | sed "s/\/[^\/]\+$/\//"`

echo resulting variable VSIS3_SRC="$VSIS3_SRC"
echo resulting variable LOCALNAME="$LOCALNAME"
echo resulting variable S3DIR="$S3DIR"

echo To produce "$S3_DEST_SHP"
VSIS3_DEST=`echo "$S3_DEST_SHP" | sed "s/^s3../\/vsis3/"`
LOCALNAME_DEST=`echo "$VSIS3_DEST" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR_DEST=`echo "$S3_DEST_SHP" | sed "s/\/[^\/]\+$/\//"`
echo resulting variable VSIS3_DEST="$VSIS3_DEST"
echo resulting variable LOCALNAME_DEST="$LOCALNAME_DEST"
echo resulting variable S3DIR_DEST="$S3DIR_DEST"

if [ `./exists.py "$S3DIR_DEST""$LOCALNAME_DEST.shp"` == "True" ] 
then 
  echo "$S3DIR_DEST""$LOCALNAME_DEST.shp" already exists
  exit 0
fi

gdal_translate -co compress=DEFLATE -b 1 -ot byte -scale 1 1 "$VSIS3_SRC" "$LOCALNAME_DEST".tif 
#gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946/TestObject.tif output.tif 
echo Starting Polygonise
/usr/bin/gdal_polygonize.py "$LOCALNAME_DEST".tif "$LOCALNAME_DEST".shp
echo AWS commit
/usr/local/bin/aws s3 cp . "$S3DIR_DEST" --recursive --exclude "*" --include "$LOCALNAME_DEST*" --exclude "*.tif" 
