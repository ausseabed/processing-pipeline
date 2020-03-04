#!/usr/bin/python3
"""
This program merges a list of shapefiles using ogrmerge

TODO: replace print strings with logging, ensure warnings to stderr are captured
TODO: testcase
"""
import subprocess
import argparse
from functools import reduce
from shlex import quote
import re
from os import path
from merge_polygon_input import MergePolygonInput

def merge_two_polygons(polygon_a, polygon_b):
    """
    merge the two using ogrmerge   
    """

    cmd = ["ogrmerge.py","-single","-append","-o",quote(polygon_a), quote(polygon_b)]
    # TODO only for debugging
    #prepend = ["sudo","docker","run","--rm","-v","/home:/home","-e", "AWS_NO_SIGN_REQUEST=YES","osgeo/gdal:ubuntu-small-latest"]
    # cmd=prepend+cmd
    print(" ".join(cmd))
    try:
        subprocess.check_output(cmd)
    except subprocess.CalledProcessError as exc:
        print("Status : FAIL", exc.returncode, exc.output)
        exit(exc.returncode)
        
    return polygon_a

def move_polygon_from_s3(polygon_dest, polygon_src):
    """
    Download the first polygon
    """
    cmd = ["ogr2ogr","-f","ESRI Shapefile", quote(polygon_dest),quote(polygon_src)]
    # TODO only for debugging
    #prepend = ["sudo","docker","run","--rm","-v","/home:/home","-e", "AWS_NO_SIGN_REQUEST=YES","osgeo/gdal:ubuntu-small-latest"]
    # cmd=prepend+cmd
    print(" ".join(cmd))
    try:
        subprocess.check_output(cmd)
    except subprocess.CalledProcessError as exc:
        print("Status : FAIL", exc.returncode, exc.output)
        exit(exc.returncode)

def upload_to_s3(result_file_name_without_ext, destination_folder):
    """ upload a shapefile to s3
    :type result_file_name_without_ext: string
    :param result_file_name_without_ext: the name of the file to shift
    :type destination_folder: string
    :param destination_folder: the location in s3 to place the file
    """ 
    cmd = ["/usr/local/bin/aws", "s3","cp",".",destination_folder,"--recursive","--exclude","\"*\"","--include","{}*".format(quote(result_file_name_without_ext))]
    try:
        subprocess.check_output(cmd)
    except subprocess.CalledProcessError as exc:
        print("Status : FAIL", exc.returncode, exc.output)
        exit(exc.returncode)

def merge_polygons():
    """
    load the inputs from environment (see MergeInputs), merge them together
    """
    input_objs = MergePolygonInput()
    input_objs.load_from_environment()
    destination_name=input_objs.get_destination()
    # TODO only for debugging
    destination_file_name = '/home/ubuntu/src/ausseabed-processing-pipeline/gdal' + re.sub(".*/", "/",destination_name)

    files = input_objs.get_source_files()
    vs_file_names = [name.replace("s3://","/vsis3/") for name in files]

    # the first file is the target of the merge
    move_polygon_from_s3(destination_file_name,vs_file_names[0])
    vs_file_names[0]=destination_file_name

    # combine all the polygons into one
    result_file_name_with_ext = reduce(merge_two_polygons,vs_file_names)

    destination_folder = re.sub("/[^/]*$", "",destination_name) # replace 
    result_file_name_without_ext = re.sub(r"\.shp", "",result_file_name_with_ext, flags=re.I)
    upload_to_s3(result_file_name_without_ext, destination_folder)



if __name__ == '__main__':
    merge_polygons()