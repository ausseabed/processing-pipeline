#!/bin/sh -e
echo Starting script
env

# Create and run from a temporary folder
tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX -p "$PWD")
echo $tmp_dir
cd $tmp_dir

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

if [ `/usr/src/app/exists.py "$S3DIR_DEST""$LOCALNAME_DEST.shp"` == "True" ] 
then 
  echo "$S3DIR_DEST""$LOCALNAME_DEST.shp" already exists
  exit 0
fi

echo "Create raster mask (1 across whole region)"
gdal_translate -co compress=DEFLATE -b 1 -a_nodata  255 -ot byte -scale 1 1 1 1 "$VSIS3_SRC" "$LOCALNAME_DEST"_a.tif 

echo "Growing by a few pixels"
/usr/bin/gdal_fillnodata.py -md 3 "$LOCALNAME_DEST"_a.tif "$LOCALNAME_DEST".tif -co compress=DEFLATE

export CHECK_DISK_FREE_SPACE=FALSE

echo "Identifying the cells one shy of the current edge"
# Create an output tif because the NoData value is inherited from the output
cp "$LOCALNAME_DEST".tif "$LOCALNAME_DEST"_prox.tif
/usr/bin/gdal_proximity.py "$LOCALNAME_DEST"_prox.tif "$LOCALNAME_DEST"_prox.tif -distunits PIXEL -values 1 -maxdist 1 -co compress=DEFLATE

echo "Highlight the internal pixels (with value 1)"
# Create an output tif because the NoData value is inherited from the output
cp "$LOCALNAME_DEST"_prox.tif "$LOCALNAME_DEST"_prox2.tif
/usr/bin/gdal_proximity.py "$LOCALNAME_DEST"_prox2.tif "$LOCALNAME_DEST"_prox2.tif -distunits PIXEL -values 1 -maxdist 3 -fixed-buf-val 0 -co compress=DEFLATE -use_input_nodata YES

echo "Combine the rasters to form a mask"
# Runs out of memory - but quicker
#/usr/bin/gdal_merge.py -o "$LOCALNAME_DEST"_prox3.tif -n 255 -a_nodata 0 -co compress=DEFLATE "$LOCALNAME_DEST".tif "$LOCALNAME_DEST"_prox2.tif
/usr/bin/gdalwarp -co compress=DEFLATE -dstnodata 0 -srcnodata 255 -ot byte -wm 6144 -co tiled=YES "$LOCALNAME_DEST".tif "$LOCALNAME_DEST"_prox2.tif "$LOCALNAME_DEST"_prox3.tif

echo "Starting polygonise"
/usr/bin/gdal_polygonize.py -8 "$LOCALNAME_DEST".tif -mask "$LOCALNAME_DEST"_prox3.tif  polies.shp 

# calculating scaling factor
if [ -z "${SCALING_FACTOR}" ] 
then
  SCALING_FACTOR_SQ=1
else
  SCALING_FACTOR_SQ=`echo "$SCALING_FACTOR * $SCALING_FACTOR" | bc`
fi
echo SCALING_FACTOR_SQ = $SCALING_FACTOR_SQ

gdalinfo "$LOCALNAME_DEST"_a.tif 

if [ -z "${SIMPLIFY_CELL_SIZE}" ] 
then
  echo "SIMPLIFY_CELL_SIZE not set - esimated cell size"
  cell_size=`gdalinfo "$LOCALNAME_DEST"_a.tif | grep "Pixel Size" | sed "s/.*([-]\?//" | sed "s/,.*//"`
  SIMPLIFY_CELL_SIZE=`echo "$cell_size * 5" | bc`
fi

SIMPLE_AREA=`echo "$SIMPLIFY_CELL_SIZE * $SIMPLIFY_CELL_SIZE" | bc`

echo "SIMPLE AREA THRESHOLD = $SIMPLE_AREA"

echo "Creating single polygon"
ogr2ogr poly_min.shp polies.shp -dialect sqlite -sql "SELECT ST_UNION(geometry) AS geometry FROM polies WHERE Area(geometry) > $SIMPLE_AREA"

echo "Adding area calcs"
ogr2ogr area.shp poly_min.shp -sql "SELECT *, CAST(OGR_GEOM_AREA * $SCALING_FACTOR_SQ / 1000000 AS float(19)) AS area_km2 FROM poly_min"

echo "New cell size = $SIMPLIFY_CELL_SIZE"

echo "Simplifying polygon"
ogr2ogr "$LOCALNAME_DEST".shp area.shp -simplify $SIMPLIFY_CELL_SIZE

echo "Creating single polygon exactly replicating raster (for areas)"

echo "Polygonise from original"
/usr/bin/gdal_polygonize.py -8 "$LOCALNAME_DEST"_a.tif polies_a.shp 

echo "Creating single polygon exactly replicating raster"
ogr2ogr poly.shp polies_a.shp -dialect sqlite -sql "SELECT ST_Collect(geometry) AS geometry FROM polies_a"

echo "Adding area calcs to single polygon exactly replicating raster"
ogr2ogr "$LOCALNAME_DEST"_full.shp poly.shp -sql "SELECT *, CAST(OGR_GEOM_AREA * $SCALING_FACTOR_SQ / 1000000 AS float(19)) AS area_km2 FROM poly"

echo "Copying area calcs from high res to low res"
mv "$LOCALNAME_DEST".dbf "$LOCALNAME_DEST".dbf.bak
cp "$LOCALNAME_DEST"_full.dbf "$LOCALNAME_DEST".dbf

echo "AWS commit"
/usr/local/bin/aws s3 cp . "$S3DIR_DEST" --recursive --exclude "*" --include "$LOCALNAME_DEST*" --exclude "*.tif" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=id="$S3_ACCOUNT_CANONICAL_ID"

cd ..
rm -rf $tmp_dir
