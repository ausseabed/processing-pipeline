import sys, os
from requests.auth import HTTPBasicAuth

class ConnectionParameters():
    """ 
    Class that houses connection parameters and reads from a datasource 
    such as environmental variables
    """
    def __init__(self ):
        self.geoserver_url = ""
        self.geoserver_password = ""

    def get_auth(self):
        return HTTPBasicAuth('admin', self.geoserver_password)

    def load_from_commandline(self):
        """ Load parameters from environment variables GEOSERVER_URL / GEOSERVER_ADMIN_PASSWORD 
        """
        try:
            self.geoserver_url = os.environ['GEOSERVER_URL']
        except KeyError:
            print("Please set the environment variable GEOSERVER_URL")
            sys.exit(1)

        print("GEOSERVER_URL = " + self.geoserver_url)

        try:
            self.geoserver_password = os.environ['GEOSERVER_ADMIN_PASSWORD']
        except KeyError:
            print("Please set the environment variable GEOSERVER_ADMIN_PASSWORD")
            sys.exit(1)
