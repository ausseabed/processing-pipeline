#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
ARG IMAGE_VERSION=9.0.7-jre8

## The Geoserver version
ARG GS_VERSION=2.16.2

FROM kartoza/geoserver:2.16.2
USER root

WORKDIR /usr/src/app

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

RUN apt-get update -y && \ 
apt-get install -y unzip curl && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install 

COPY geoserverpush/logging.xml /opt/geoserver/data_dir/logging.xml
RUN chmod +r /opt/geoserver/data_dir/logging.xml

COPY geoserverpush/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir /usr/local/pulldata
RUN chmod +rx /usr/local/pulldata
COPY geoserverpush/*.sld /usr/local/pulldata/
COPY geoserverpush/*.py /usr/local/pulldata/
RUN chmod +r /usr/local/pulldata/*.sld
RUN chmod +rx /usr/local/pulldata/*.py
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
