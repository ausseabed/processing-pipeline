import logging
import boto3
from fnmatch import fnmatch
from pathlib import Path
import subprocess
import tempfile
import time
from botocore.exceptions import ClientError

class S3IO:
    """
    From Wenjun's MB System's pipeline
    """
    s3 = boto3.client('s3')
    b_name = None

    def __init__(self, bucket):
        '''
        :param bucket: Name of a S3 bucket.
        '''
        self.b_name = bucket

    def list_keys(self, prefix='', pattern='*'):
        '''
        Generate the matching keys (iterable) in an S3 bucket.

        :param prefix: required matching prefix (optional).
        :param pattern: required Unix filename matching pattern (optional).
        '''
        for obj in self.list_objects(prefix=prefix, pattern=pattern):
            yield obj['Key']

    def list_objects(self, prefix='', pattern='*'):
        '''
        Generate the matching objects (iterable) in an S3 bucket.

        :param prefix: required matching prefix (optional).
        :param pattern: required Unix filename matching pattern (optional).
        '''
        args = {'Bucket': self.b_name}
        if isinstance(prefix, str):
            args['Prefix'] = prefix

        while True:
            resp = self.s3.list_objects_v2(**args)
            if 'Contents' not in resp.keys():
                return
            for obj in resp['Contents']:
                if fnmatch(obj['Key'], pattern):
                    yield obj
            try:
                args['ContinuationToken'] = resp['NextContinuationToken']
            except KeyError:
                break

    def get_object(self, key):
        '''
        Retrieve an open StreamingBody object for a given key

        :param key: string
        :return: botocore.response.StreamingBody object.
                 If error, return None.
        '''

        # Retrieve the object
        try:
            response = self.s3.get_object(Bucket=self.b_name, Key=key)
        except ClientError as e:
            # AllAccessDisabled error == bucket or object not found
            # logging.error(e)
            return None
        # Return an open StreamingBody object
        return response['Body']

    def get_content(self, key):
        '''
        Retrieve the content of a given object

        :param key: string
        :return: bytes
        '''
        result = None
        stream = self.get_object(key)
        if stream is not None:
            result = stream.read()
            stream.close()
        return result

    def put_object(self, dest_key, object_data):
        '''
        Add an object to an Amazon S3 bucket.
        The object_data argument must be of type bytes.

        :param dest_key: string
        :param object_data: bytes of data
        :return: True if src_data was added, otherwise False
        '''
        try:
            self.s3.put_object(Bucket=self.b_name,
                               Key=dest_key,
                               Body=object_data)
        except ClientError as e:
            # AllAccessDisabled error == bucket not found
            # NoSuchKey or InvalidRequest error
            # logging.error(e)
            return False
        return True

    def download_file(self, key, filepath):
        '''
        Download an object and save to the specified file.

        :param key: the key of an S3 object
        :param filepath: the destination Path object
        '''
        filepath.parent.mkdir(parents=True, exist_ok=True)
        self.s3.download_file(self.b_name, key, str(filepath))

    def download_files(self, keys, directory, cut_dirs=0):
        '''
        Download objects and save to the specified directory.

        :param keys: a list of keys
        :param directory: the destination directory to save files
        :param cut_dirs: specified the number of directories to be ommited
                         to from a key
        '''
        for key in keys:
            pk = Path(key)
            ndir = '/'.join(pk.parent.parts[cut_dirs:])
            p = Path(directory, ndir, pk.name)
            self.download_file(key, p)

    def upload_file(self, local_filepath, s3_key, extra_args=None):
        '''
        Upload a file to the S3 bucket with a specified s3 key.

        :param local_filepath: the source file (Path object)
        :param s3_key: the key of the destination S3 object
        '''
        self.s3.upload_file(str(local_filepath), self.b_name, s3_key,
                            ExtraArgs=extra_args)


    def upload_directory(self, local_dirpath, s3_prefix):
        '''
        Upload all files under a local directory
        to the S3 bucket with a specified s3 prefix.

        :param local_dirpath: the source directory (Path object)
        :param s3_prefix: the s3 prefix of the destination
        '''
        cmd = ['aws', 's3', 'sync', str(local_dirpath),
               's3://{}/{}/'.format(self.b_name, s3_prefix),
               '--sse']
        subprocess.check_call(cmd, stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL)

    def delete_keys(self, keys):
        '''
        Delete objects from an S3 bucket.

        :param keys: a list of keys
        '''
        objs = [{'Key': key} for key in keys]
        #
        # make sure only pass maximum 1000 objects to s3.delete_objects()
        #
        s_max = 1000
        s_start = 0
        while True:
            s_stop = s_start + s_max
            s_objs = objs[slice(s_start, s_stop)]
            if len(s_objs) == 0:
                break
            self.s3.delete_objects(
                Bucket=self.b_name,
                Delete={
                    'Objects': s_objs,
                    'Quiet': True
                },
            )
            s_start += s_max

    def is_newer(self, obj1, obj2):
        '''
        Return True if obj1 is newer than obj2

        :param obj1: an S3 object return by list_objects()
        :param obj2: an S3 object return by list_objects()
        '''
        return obj1['LastModified'] >= obj2['LastModified']
