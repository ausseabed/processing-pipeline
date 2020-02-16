#!/bin/sh
echo Starting script
env

set -x
# test with export AWS_NO_SIGN_REQUEST=YES
# S3_SRC_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy.tif"
# S3_DEST_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy_Overlay.tif"



echo Starting translate of "$S3_SRC_TIF"
VSIS3_SRC=`echo "$S3_SRC_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME_SRC=`echo "$VSIS3_SRC" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR_SRC=`echo "$S3_SRC_TIF" | sed "s/\/[^\/]\+$/\//"`
echo resulting variable VSIS3="$VSIS3_SRC"
echo resulting variable LOCALNAME="$LOCALNAME_SRC"
echo resulting variable S3DIR="$S3DIR_SRC"

echo Starting translate of "$S3_DEST_TIF"
VSIS3_DEST=`echo "$S3_DEST_TIF" | sed "s/^s3../\/vsis3/"`
LOCALNAME_DEST=`echo "$VSIS3_DEST" | sed "s/.*\///" | sed "s/\.[^\.]\+$//"`
S3DIR_DEST=`echo "$S3_DEST_TIF" | sed "s/\/[^\/]\+$/\//"`
echo resulting variable VSIS3="$VSIS3_DEST"
echo resulting variable LOCALNAME="$LOCALNAME_DEST"
echo resulting variable S3DIR="$S3DIR_DEST"

echo Copying local
gdal_translate -co compress=lzw -co "TILED=YES" "$VSIS3_SRC" "$LOCALNAME_DEST".tif 

echo Adding overlays
gdaladdo -r average "$LOCALNAME_DEST".tif 2 4 8 16
echo AWS commit
/usr/local/bin/aws2 s3 cp . "$S3DIR_DEST" --recursive --include "$LOCALNAME_DEST*"  --exclude "*" 
