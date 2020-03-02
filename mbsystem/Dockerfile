FROM mbari/mbsystem


# Install AWS CLI Client (and restore python3 link for gdal)
# apt-get for ubuntu, yum for centos
RUN yum update -y && \ 
yum install unzip curl && \
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install 

RUN curl -L https://github.com/LAStools/LAStools/archive/master.zip -o LAStools.zip && \
unzip LAStools.zip && \
cd LAStools-master && \
make && cd bin && cp las2las las2txt lasdiff lasindex lasinfo lasmerge lasprecision laszip txt2las /usr/bin/

WORKDIR /usr/src/app

COPY *.sh /usr/src/app/
RUN chmod +x /usr/src/app/*.sh

CMD ["./convert-to-las.sh"] 

