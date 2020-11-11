#!/usr/bin/python3
import boto3
from urllib.parse import urlparse
import logging
import sys
from botocore.errorfactory import ClientError
logging.basicConfig(level=logging.ERROR)


class S3Exists():
    def __init__(self, s3url):
        self.s3url = s3url

    def exists(self):
        o = urlparse(self.s3url,
                     allow_fragments=False)
        bucket = o.netloc
        s3_key = o.path.lstrip('/')
        client = boto3.client('s3')
        try:
            client.head_object(Bucket=bucket, Key=s3_key)
        except ClientError:
            # Not found
            logging.debug("File does not exist - s3://%s/%s " %
                          (bucket, s3_key))
            return False
        logging.debug("File exists - s3://%s/%s " % (bucket, s3_key))
        return True
 

if __name__ == '__main__':
    s3Exists = S3Exists(str(sys.argv[1]))
    if s3Exists.exists():
        print(True)
    else:
        print(False)
