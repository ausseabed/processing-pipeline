
# Have to use the ubuntu version for the AWS installer to work
FROM osgeo/gdal:ubuntu-small-latest

# Install AWS CLI Client (and restore python3 link for gdal)
RUN apt-get update -y && \ 
apt-get install unzip curl && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install 

RUN apt-get update && apt-get install -y python3-pip && \
pip3 install boto3

WORKDIR /usr/src/app

COPY *.sh /usr/src/app/
RUN chmod +x /usr/src/app/*.sh
COPY *.py /usr/src/app/
RUN chmod +x /usr/src/app/*.py

CMD ["./polygon.sh"] 
