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

gdal_translate -co compress=DEFLATE -b 1 -ot byte -scale 1 1 "$VSIS3_SRC" "$LOCALNAME_DEST".tif 
#gdal_translate -co compress=lzw -b 1 -ot byte -scale 1 1 /vsis3/bathymetry-survey-288871573946/TestObject.tif output.tif 
echo Starting polygonise
/usr/bin/gdal_polygonize.py "$LOCALNAME_DEST".tif polies_"$LOCALNAME_DEST".shp 

echo Creating single polygon exactly replicating raster
ogr2ogr poly_"$LOCALNAME_DEST".shp polies_"$LOCALNAME_DEST".shp -dialect sqlite -sql "SELECT ST_Union(geometry) AS geometry FROM polies_$LOCALNAME_DEST"

echo Adding area calcs to single polygon exactly replicating raster
ogr2ogr "$LOCALNAME_DEST"_full.shp poly_"$LOCALNAME_DEST".shp -sql "SELECT *, OGR_GEOM_AREA AS area FROM poly_$LOCALNAME_DEST"

gdalinfo "$LOCALNAME_DEST".tif 

if [ -z "${SIMPLIFY_CELL_SIZE}" ] 
then
  echo "SIMPLIFY_CELL_SIZE not set - esimated cell size"
  cell_size=`gdalinfo "$LOCALNAME_DEST".tif | grep "Pixel Size" | sed "s/.*([-]\?//" | sed "s/,.*//"`
  SIMPLIFY_CELL_SIZE=`echo "$cell_size * 5" | bc`
fi

SIMPLE_AREA=`echo "$SIMPLIFY_CELL_SIZE * $SIMPLIFY_CELL_SIZE" | bc`

echo Creating single polygon
ogr2ogr poly_min_"$LOCALNAME_DEST".shp polies_"$LOCALNAME_DEST".shp -dialect sqlite -sql "SELECT ST_Union(geometry) AS geometry FROM polies_$LOCALNAME_DEST WHERE Area(geometry) > $SIMPLE_AREA"

echo Adding area calcs
ogr2ogr area_"$LOCALNAME_DEST".shp poly_min_"$LOCALNAME_DEST".shp -sql "SELECT *, OGR_GEOM_AREA AS area FROM poly_min_$LOCALNAME_DEST"


echo New cell size = $SIMPLIFY_CELL_SIZE

echo Simplifying polygon
ogr2ogr "$LOCALNAME_DEST".shp area_"$LOCALNAME_DEST".shp -simplify $SIMPLIFY_CELL_SIZE

echo AWS commit
/usr/local/bin/aws s3 cp . "$S3DIR_DEST" --recursive --exclude "*" --include "$LOCALNAME_DEST*" --exclude "*.tif" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=id="$S3_ACCOUNT_CANONICAL_ID"
