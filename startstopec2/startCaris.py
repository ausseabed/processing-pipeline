import boto3
import os,sys
import logging


LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()
logging.basicConfig(level=LOGLEVEL)

caris_instance_ids = ['i-028b1113e477f26d3']
exit_status = 1

ec2 = boto3.client('ec2')
logging.info('starting: '+ str(caris_instance_ids))
response = ec2.start_instances(InstanceIds=caris_instance_ids)

instance_status =  response['StartingInstances'][0]['CurrentState']['Name']

while instance_status not in ['running']:
     logging.info('trying again as status is '+instance_status)
     response = ec2.start_instances(InstanceIds=caris_instance_ids)
     instance_status =  response['StartingInstances'][0]['CurrentState']['Name']

logging.info('started: '+ str(caris_instance_ids))
exit_status = 0
sys.exit(exit_status)