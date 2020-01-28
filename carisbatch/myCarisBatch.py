#!/usr/bin/env python

import sys, paramiko, io, os
import boto3
import argparse
import select

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

def exec_process_wrapper(ssh, cmd):
    """ exec_process_wrapper runs a ssh command - dealing with chunking output between processes
    exec_process_wrapper is based on https://stackoverflow.com/questions/23504126/do-you-have-to-check-exit-status-ready-if-you-are-going-to-check-recv-ready/32758464#32758464
    user contributions licensed under cc by-sa 4.0 author - tinti
    :type ssh: SSH2 channel
    :param ssh: Channel to connect to process

    :type cmd: string
    :param cmd: Command to run on remote process

    :rtype: string
    :return: returns standard output + standard error concatenated together
    """
    #one channel per command
    stdin, stdout, stderr = ssh.exec_command(cmd) 
    # get the shared channel for stdout/stderr/stdin
    channel = stdout.channel

    # we do not need stdin.
    stdin.close()                 
    # indicate that we're not going to write to that channel anymore
    channel.shutdown_write()      

    # read stdout/stderr in order to prevent read block hangs
    print(stdout.channel.recv(len(stdout.channel.in_buffer)))
    # chunked read to prevent stalls
    while not channel.closed or channel.recv_ready() or channel.recv_stderr_ready(): 
        # stop if channel was closed prematurely, and there is no data in the buffers.
        got_chunk = False
        readq, _, _ = select.select([stdout.channel], [], [])
        for c in readq:
            if c.recv_ready(): 
                print(stdout.channel.recv(len(c.in_buffer)))
                got_chunk = True
            if c.recv_stderr_ready(): 
                # make sure to read stderr to prevent stall    
                print(stderr.channel.recv_stderr(len(c.in_stderr_buffer)))
                got_chunk = True
        '''
        1) make sure that there are at least 2 cycles with no data in the input buffers in order to not exit too early (i.e. cat on a >200k file).
        2) if no data arrived in the last loop, check if we already received the exit code
        3) check if input buffers are empty
        4) exit the loop
        '''
        if not got_chunk \
            and stdout.channel.exit_status_ready() \
            and not stderr.channel.recv_stderr_ready() \
            and not stdout.channel.recv_ready(): 
            # indicate that we're not going to read from this channel anymore
            stdout.channel.shutdown_read()  
            # close the channel
            stdout.channel.close()
            break    # exit as remote side is finished and our bufferes are empty

    # close all the pseudofiles
    stdout.close()
    stderr.close()

    # exit code is always ready at this point
    return (stdout.channel.recv_exit_status())
    


def line_buffered(f):
    line_buf = ""
    while not f.channel.exit_status_ready():
        line_buf += f.readline(1)
        if line_buf.endswith('\n'):
            yield line_buf
            line_buf = ''


# initiate the parser
parser = argparse.ArgumentParser()

# add long and short argument
parser.add_argument("--ip", "-ip", help="set ip if using external caris instance")
parser.add_argument("--command", "-c", help="the command to run in caris windows machine")

# read arguments from the command line
args = parser.parse_args()

hostname = None
if args.ip:
    print("using external caris instance %s" % args.ip)
    hostname = args.ip
else:
    res = find_caris_ip()
    hostname = res['Reservations'][0]['Instances'][0]['PublicIpAddress']

command = args.command
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
    
    client.connect(hostname, port=port, username=username,  pkey=private_key)

    exit_status=exec_process_wrapper(client,command)
    sys.exit(exit_status)
except Exception  as e:
    print(e)
    sys.exit(1)
finally:
    client.close()
