#!/usr/bin/env python

import sys, paramiko, io, os

if len(sys.argv) < 2:
    print("args missing")
    sys.exit(1)

hostname = sys.argv[1]
command = sys.argv[2]
password = sys.argv[3]
key_env_var_name = sys.argv[4]
print(key_env_var_name)
username = "Administrator"
port = 22

key_string = """q
key_string = os.environ[key_env_var_name]
""" # I saved my key in this string
not_really_a_file = io.StringIO(key_string)
print(key_string)
private_key = paramiko.RSAKey.from_private_key(not_really_a_file,password=password)

not_really_a_file.close()



try:
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy(paramiko.WarningPolicy)
    
    #client.connect(hostname, port=port, username=username, password=password, key_filename=key_filename)
    client.connect(hostname, port=port, username=username,  pkey=private_key)

    stdin, stdout, stderr = client.exec_command(command)
    print(stdout.read(), end=' ')

finally:
    client.close()