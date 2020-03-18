import boto3
import os,sys
import logging


LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()
logging.basicConfig(level=LOGLEVEL)

# Find instances that could have a caris license
# If we find one that is licensed and running, do nothing
# If we find one that is licensed and not running, start machine and attach license

def find_caris_instances(has_license="yes", running_status='running'):
    client = boto3.client('ec2')
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:CARISLicensed',
                'Values': [ has_license ]
            },
            {
                'Name': 'instance-state-name',
                'Values': [ running_status ]
            },
            
        ]
    )
    return response


response=find_caris_instances(has_license="yes",running_status="running")
if (len(response['Reservations'][0]['Instances'])>0):
     hostname = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
     logging.info('found running instance: '+ str(hostname))
     exit(0)

logging.error("We cannot currently start up a machine and associate a license")
exit(1)

# TODO NGA-260 attach a license to a stopped EC2 instance
caris_instance_ids = ['i-075f254af9700e8cb']
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