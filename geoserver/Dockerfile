#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
ARG IMAGE_VERSION=9.0.7-jre8

## The Geoserver version
ARG GS_VERSION=2.16.1
ARG COMMUNITY_MODULES=true

FROM kartoza/geoserver

WORKDIR /usr/src/app

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

COPY geoserverpush/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY geoserverpush/push_geoserver_settings.py /usr/local/pulldata/push_geoserver_settings.py
RUN chmod +x /usr/local/pulldata/push_geoserver_settings.py
COPY ausseabed.pipeline/target/*.jar /usr/local/tomcat/lib
COPY tomcat/conf/server.xml /usr/local/tomcat/conf 

# 3 environmental variables are required for running
# GEOSERVER_URL = "http://ec2-54-153-228-148.ap-southeast-2.compute.amazonaws.com/geoserver"
# GEOSERVER_ADMIN_PASSWORD = 
# LIST_PATH = "https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
#  the file at the end of the path is a json encoded list of dictionary entries indexed by filename - e.g.,
#  [{"filename": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m_coloured.tif"}]

ENV \
    ## Initial Memory that Java can allocate
    INITIAL_MEMORY="500M" \
    ## Maximum Memory that Java can allocate
    MAXIMUM_MEMORY="1000M" \
    S3_SERVER_URL='' \
    S3_USERNAME='' \
    S3_PASSWORD='' \
    GEOSERVER_URL='http://localhost:8080/geoserver' \
    TOMCAT_POST_INIT_SCRIPT='/usr/local/pulldata/push_geoserver_settings.py'


CMD ["/scripts/entrypoint.sh"]
