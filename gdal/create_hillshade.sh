#!/bin/sh
# create_hillshade.sh creates a hillshade for bathymetry for presentation purposes
# requires environment variables:
# S3_SRC_TIF
# S3_DEST_TIF
# SCALING_FACTOR (111120 for geographic, 1 for projection with horizontal unit of metres)

echo Starting script

# test with export AWS_NO_SIGN_REQUEST=YES
# S3_SRC_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy.tif"
# S3_DEST_TIF="s3://ausseabed-public-bathymetry/L3/68f44afd-78d0-412f-bf9c-9c9fdbe43968/01_Bathy_Overlay.tif"

echo "S3_ACCOUNT_CANONICAL_ID=$S3_ACCOUNT_CANONICAL_ID"
echo Starting translate of "$S3_SRC_TIF"
echo Scaling factor = "$SCALING_FACTOR"
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

SIZE=`aws s3 ls "$S3_SRC_TIF" | head -1 | awk '{print $3}'`

TARGET="$VSIS3_SRC"
if [ $SIZE -lt 3000000000 ]
then 
  echo "Copying local to speed up processing (can't do this for very large grids)"
  TARGET="$LOCALNAME_DEST"_local.tif 
  gdal_translate -co compress=DEFLATE -co TILED=YES -co BIGTIFF=IF_SAFER "$VSIS3_SRC" "$TARGET" 
fi

echo Creating hillshade
gdaldem hillshade -co compress=DEFLATE -co TILED=YES -co BIGTIFF=IF_SAFER "$TARGET" "$LOCALNAME_DEST"_in.tif -az 30 -alt 45 -z 2 -s "$SCALING_FACTOR"

echo Adding overlays
gdaladdo -r average "$LOCALNAME_DEST"_in.tif 2 4 8 16 32

echo Ensuring cloud optimised layout
gdal_translate -co compress=DEFLATE -co LEVEL=9 -co TILED=YES -co BIGTIFF=IF_SAFER -co COPY_SRC_OVERVIEWS=YES -of COG "$LOCALNAME_DEST"_in.tif "$LOCALNAME_DEST".tif 

echo AWS commit
/usr/local/bin/aws s3 cp "$LOCALNAME_DEST".tif "$S3DIR_DEST""$LOCALNAME_DEST.tif" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=id="$S3_ACCOUNT_CANONICAL_ID"
