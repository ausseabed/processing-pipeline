#!/usr/bin/env python

import sys, paramiko, io, os
import boto3


def find_caris_ip():
    client = boto3.client('ec2')
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'caris'
                ]
            },
            {
                'Name': 'instance-state-name',
                'Values': [
                    'running'
                ]
            },
            
        ]
    )
    return response

def line_buffered(f):
    line_buf = ""
    while not f.channel.exit_status_ready():
        line_buf += f.readline(1)
        if line_buf.endswith('\n'):
            yield line_buf
            line_buf = ''



if len(sys.argv) < 1:
    print("args missing")
    sys.exit(1)

res = find_caris_ip()
hostname = res['Reservations'][0]['Instances'][0]['PublicIpAddress']
command = sys.argv[1]
# this is the key used to encrypt the private key. 
# The encrypted private key is stored in AWS Secrets and assisible through IAM roles. 
# So, storing the password in plain text isn't making it less secure.
password = 'arnab' 
key_env_var_name = 'caris_rsa_pkey_string'
username = "Administrator"
port = 22

key_string = """-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----""" # I saved my key in this string
key_string = os.environ[key_env_var_name]

not_really_a_file = io.StringIO(key_string)

private_key = paramiko.RSAKey.from_private_key(not_really_a_file,password=password)

not_really_a_file.close()





try:
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.WarningPolicy)
    
    #client.connect(hostname, port=port, username=username, password=password, key_filename=key_filename)
    client.connect(hostname, port=port, username=username,  pkey=private_key)

    stdin, stdout, stderr = client.exec_command(command)
    for l in line_buffered(stdout):
        print(l, end=' ')
    for l in line_buffered(stderr):
        print(l, end=' ')
    exit_status = stdout.channel.recv_exit_status()
    print("exit status"+str(exit_status) )
    sys.exit(exit_status)
except Exception  as e:
    print(e)
    sys.exit(1)
finally:
    client.close()
