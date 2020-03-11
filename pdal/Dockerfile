FROM pdal/pdal


# Install AWS CLI Client (and restore python3 link for gdal)
RUN apt-get update -y && \ 
apt-get install unzip curl && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install && \
ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /usr/src/app

COPY *.sh /usr/src/app/
RUN chmod +x /usr/src/app/*.sh

CMD ["./create-extent-coverage.sh"] 

