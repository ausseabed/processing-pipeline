import sys,os
import requests

class ProductDatabase():
    def load_from_commandline(self):
        try:
            self.source_tif_path = os.environ['LIST_PATH']
        except KeyError:
            print("Please set the environment variable LIST_PATH")
            sys.exit(1)

        print("Path to file that specifies what to load (LIST_PATH) = " + self.source_tif_path)

    def get_records(self):
        # Step 1 - read in a list of source tifs
        response = requests.get(self.source_tif_path)
        if not response.ok:
            print("Error trying to get LIST_PATH")

        self.source_tifs = response.json()

        print("Number of source_tifs: " + str(len(self.source_tifs)))
        return self.source_tifs
