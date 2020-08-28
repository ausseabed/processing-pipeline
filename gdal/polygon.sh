#!/bin/sh
echo Starting script
env

# test with export AWS_NO_SIGN_REQUEST=YES

# test with s3://bathymetry-survey-288871573946/TestObject.tif

echo "S3_ACCOUNT_CANONICAL_ID=$S3_ACCOUNT_CANONICAL_ID"
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

gdal_translate -co compress=DEFLATE -b 1 -ot byte -scale 1 1 1 1 "$VSIS3_SRC" "$LOCALNAME_DEST".tif 
#gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946/TestObject.tif output.tif 
echo Starting polygonise
/usr/bin/gdal_polygonize.py "$LOCALNAME_DEST".tif polies.shp 

echo Creating single polygon exactly replicating raster
ogr2ogr poly.shp polies.shp -dialect sqlite -sql "SELECT ST_Collect(geometry) AS geometry FROM polies"

# TODO change geographic into a multiplier

echo Adding area calcs to single polygon exactly replicating raster
if [ -z "${SCALING_FACTOR}" ] 
then
  SCALING_FACTOR_SQ=1
else
  SCALING_FACTOR_SQ=`echo "$SCALING_FACTOR * $SCALING_FACTOR" | bc`
fi

ogr2ogr "$LOCALNAME_DEST"_full.shp poly.shp -sql "SELECT *, CAST(OGR_GEOM_AREA * $SCALING_FACTOR_SQ / 1000000 AS float(19)) AS area_km2 FROM poly"

gdalinfo "$LOCALNAME_DEST".tif 

if [ -z "${SIMPLIFY_CELL_SIZE}" ] 
then
  echo "SIMPLIFY_CELL_SIZE not set - esimated cell size"
  cell_size=`gdalinfo "$LOCALNAME_DEST".tif | grep "Pixel Size" | sed "s/.*([-]\?//" | sed "s/,.*//"`
  SIMPLIFY_CELL_SIZE=`echo "$cell_size * 5" | bc`
fi

SIMPLE_AREA=`echo "$SIMPLIFY_CELL_SIZE * $SIMPLIFY_CELL_SIZE" | bc`

echo Creating single polygon
ogr2ogr poly_min.shp polies.shp -dialect sqlite -sql "SELECT ST_Collect(geometry) AS geometry FROM polies WHERE Area(geometry) > $SIMPLE_AREA"

echo Adding area calcs
ogr2ogr area.shp poly_min.shp -sql "SELECT *, CAST(OGR_GEOM_AREA * $SCALING_FACTOR_SQ / 1000000 AS float(19)) AS area_km2 FROM poly_min"

echo New cell size = $SIMPLIFY_CELL_SIZE

echo Simplifying polygon
ogr2ogr "$LOCALNAME_DEST".shp area.shp -simplify $SIMPLIFY_CELL_SIZE

echo AWS commit
/usr/local/bin/aws s3 cp . "$S3DIR_DEST" --recursive --exclude "*" --include "$LOCALNAME_DEST*" --exclude "*.tif" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=id="$S3_ACCOUNT_CANONICAL_ID"
