#!/usr/bin/env python

import sys, paramiko

if len(sys.argv) < 3:
    print("args missing")
    sys.exit(1)

hostname = sys.argv[1]
command = sys.argv[2]
password = sys.argv[3]
key_filename = sys.argv[4]

username = "Administrator"
port = 22

try:
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.WarningPolicy)
    
    client.connect(hostname, port=port, username=username, password=password, key_filename=key_filename)

    stdin, stdout, stderr = client.exec_command(command)
    print(stdout.read(), end=' ')

finally:
    client.close()