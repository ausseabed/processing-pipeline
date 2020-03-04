import sys,os
import json

class MergePolygonInput():
    """ 
    Product Database data structure (at the moment a json formatted file that has the form:
 [
  {
    "instrument-file" : [
    {
    "s3_dest_shp" : "s3://bathymetry-survey-288871573946/L0Coverage/0495_20180621_105318_BlueFin.shp"
    },
    {
    "s3_dest_shp" : "s3://bathymetry-survey-288871573946/L0Coverage/0494_20180621_104350_BlueFin.shp"
    }
  ],
    "coverage-file" : "s3://bathymetry-survey-288871573946/L0Coverage/coverage.shp"
  }

    """

    def __init__(self):
        self.json_objs = None

    def load_from_environment(self):
        try:
            self.input_json= os.environ['INPUT_FILES']
        except KeyError:
            print("Please set the environment variable INPUT_FILES")
            sys.exit(1)
        self.json_objs = json.loads(self.input_json)

    def get_source_files(self):
        # TODO defensive programming
        if self.json_objs is None:
            print ("No inputs loaded")
            exit(1)
        return [record['s3_dest_shp'] for record in self.json_objs['instrument-file'] ]

    def get_destination(self):
        # TODO defensive programming
        if self.json_objs is None:
            print ("No inputs loaded")
            exit(1)
        return self.json_objs["coverage-file"]
