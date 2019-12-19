FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY push_geoserver_settings.py .

# 3 environmental variables are required for running
# GEOSERVER_URL = "http://ec2-54-153-228-148.ap-southeast-2.compute.amazonaws.com/geoserver"
# GEOSERVER_ADMIN_PASSWORD = 
# LIST_PATH = "https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
#  the file at the end of the path is a json encoded list of dictionary entries indexed by filename - e.g.,
#  [{"filename": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_coloured.tif"}]

ENTRYPOINT ["python", "./push_geoserver_settings.py"]

CMD [ "" ]
