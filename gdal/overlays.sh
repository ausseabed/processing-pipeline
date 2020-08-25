#!/bin/sh
# overlays.sh creates 'overlays' and 'tiles' for geotiffs and
# stores them internal to the .tiff. This means that Geoserver's
# S3GeoTiff plugin can read them.

echo Starting script

# test with export AWS_NO_SIGN_REQUEST=YES
# S3_SRC_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy.tif"
# S3_DEST_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy_Overlay.tif"


echo "S3_ACCOUNT_CANONICAL_ID=$S3_ACCOUNT_CANONICAL_ID"

echo Starting translate of "$S3_SRC_TIF"
VSIS3_SRC=`echo "$S3_SRC_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME_SRC=`echo "$VSIS3_SRC" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR_SRC=`echo "$S3_SRC_TIF" | sed "s/\/[^\/]\+$/\//"`
echo resulting variable VSIS3_SRC="$VSIS3_SRC"
echo resulting variable LOCALNAME_SRC="$LOCALNAME_SRC"
echo resulting variable S3DIR_SRC="$S3DIR_SRC"

echo To produce "$S3_DEST_TIF"
VSIS3_DEST=`echo "$S3_DEST_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME_DEST=`echo "$VSIS3_DEST" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR_DEST=`echo "$S3_DEST_TIF" | sed "s/\/[^\/]\+$/\//"`
echo resulting variable VSIS3_DEST="$VSIS3_DEST"
echo resulting variable LOCALNAME_DEST="$LOCALNAME_DEST"
echo resulting variable S3DIR_DEST="$S3DIR_DEST"

if [ `./exists.py "$S3DIR_DEST""$LOCALNAME_DEST.tif"` == "True" ] 
then 
  echo "$S3DIR_DEST""$LOCALNAME_DEST.tif" already exists
  exit 0
fi

df
set -x
echo Copying local
gdal_translate -co compress=DEFLATE -co TILED=YES -co BIGTIFF=IF_SAFER "$VSIS3_SRC" "$LOCALNAME_DEST"_in.tif 

df
echo Adding overlays
gdaladdo -r average "$LOCALNAME_DEST"_in.tif 2 4 8 16 32

df
echo Ensuring cloud optimised layout
gdal_translate -co compress=DEFLATE -co LEVEL=9 -co TILED=YES -co BIGTIFF=IF_SAFER -co COPY_SRC_OVERVIEWS=YES -of COG "$LOCALNAME_DEST"_in.tif "$LOCALNAME_DEST".tif 

df
echo AWS commit
/usr/local/bin/aws s3 cp "$LOCALNAME_DEST".tif "$S3DIR_DEST""$LOCALNAME_DEST.tif" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=id="$S3_ACCOUNT_CANONICAL_ID"
