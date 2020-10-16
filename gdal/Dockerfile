
# Have to use the ubuntu version for the AWS installer to work
FROM osgeo/gdal:alpine-normal-latest

# Install AWS CLI Client (and restore python3 link for gdal)
ENV GLIBC_VER=2.31-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \        
        nfs-utils \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

RUN apk update && apk add python3 && apk add py3-pip && \
pip3 install boto3

# RUN apk add --no-cache gcc libffi-dev musl-dev openssl-dev make bash
RUN apk add --no-cache dpkg binutils nfs-utils stunnel openssl util-linux git \
    && mkdir -p /tmp/efsutils \
    && cd /tmp/efsutils \
    && git clone https://github.com/aws/efs-utils . \
    && ./build-deb.sh \
    && dpkg --force-all -i ./build/amazon-efs-utils*.deb \
    && rm -Rf /tmp/efsutils
RUN sed -i '/#region = us-east-1/s/^#//' /etc/amazon/efs/efs-utils.conf && cat /etc/amazon/efs/efs-utils.conf


WORKDIR /usr/src/app

COPY *.sh /usr/src/app/
RUN chmod +x /usr/src/app/*.sh
COPY *.py /usr/src/app/
RUN chmod +x /usr/src/app/*.py

CMD ["./polygon.sh"] 
