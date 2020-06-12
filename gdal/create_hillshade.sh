#!/bin/bash
# create_hillshade.sh creates a hillshade for bathymetry for presentation purposes

echo Starting script

# test with export AWS_NO_SIGN_REQUEST=YES
# S3_SRC_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy.tif"
# S3_DEST_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy_Overlay.tif"

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

set -x
echo Creating hillshade
gdaldem hillshade -co compress=DEFLATE -co TILED=YES -co BIGTIFF=IF_SAFER "$VSIS3_SRC" "$LOCALNAME_DEST".tif -az 30 -alt 45 -s 2

echo Adding overlays
gdaladdo -r average "$LOCALNAME_DEST".tif 2 4 8 16
echo AWS commit
/usr/local/bin/aws s3 cp "$LOCALNAME_DEST".tif "$S3DIR_DEST""$LOCALNAME_DEST.tif"
