import sys,os
import json

class MergePolygonInput():
    """ 
    Product Database data structure from environment variables
  e.g. 
  "INPUT_FILES_1", "s3://bathymetry-survey-288871573946/Rawdata/0495_20180621_105318_BlueFin.all"
  "INPUT_FILES_2", "s3://bathymetry-survey-288871573946-1/Rawdata/0494_20180621_104350_BlueFin.all"
  "COVERAGE_FILE", "s3://bathymetry-survey-288871573946/L0Coverage/coverage.shp"
    """

    def __init__(self):
        self.str_inputs = []
        self.str_output=""

    def load_from_environment(self):      
        self.str_inputs=[os.environ[env_variable] for env_variable in os.environ.keys() if env_variable.startswith('INPUT_FILES')]

        if len(self.str_inputs)==0:
            print("Please set the environment variable INPUT_FILES")
            sys.exit(1)
            
        try:
            self.str_output= os.environ['COVERAGE_FILE']
        except KeyError:
            print("Please set the environment variable COVERAGE_FILE")
            sys.exit(1)

    def get_source_files(self):
        return self.str_inputs

    def get_destination(self):
        return self.str_output
