#!/usr/bin/python3
# https://gist.github.com/y60/0f78a4228eba7c8ed1dc319a9960b05e#file-docker_add_subugids-py
import subprocess
import argparse

def pair(arg):
    # For simplity, assume arg is a pair of integers
    # separated by a comma. If you want to do more
    # validation, raise argparse.ArgumentError if you
    # encounter a problem.
    return [int(x) for x in arg.split(':')]

parser = argparse.ArgumentParser()
parser.add_argument('--uid-maps', type=pair, nargs='+')
parser.add_argument('--gid-maps', type=pair, nargs='+')

args = parser.parse_args()

print('uid maps (host:container) :', args.uid_maps)
print('gid maps (host:container) :', args.gid_maps)

subuid_path = '/etc/subuid'
subgid_path = '/etc/subgid'

# Get the list of LDAP users via $getent passwd
proc = subprocess.run(['getent', 'passwd'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
user_list = proc.stdout.decode('utf8').split('\n')
user_list = [user.split(':') for user in user_list]
# The filter 10000 <= uid <= 30000 is used to eliminate system users. This should be changed according to your own environment 
user_list = [user[0] for user in user_list if len(user[0]) > 0 and 30000 <= int(user[2]) <= 60000]

# Get the list of users already registered in /etc/subuid and /etc/subgid
def get_subugids(file_path):
    with open(file_path) as f:
        ids = [line.split(':') for line in f]
    users = {subid[0] for subid in ids}
    
    next_id_begin = 100000
    if len(ids) > 0:
        _, last_id_begin, last_id_count = max(ids, key=lambda item: int(item[1]))
        next_id_begin = max(int(last_id_begin) + int(last_id_count), next_id_begin)
        
    assert next_id_begin >= 100000
    return users, ids, next_id_begin

existing_users, subuids, next_uid_begin = get_subugids(subuid_path)
existing_users2, subgids, next_gid_begin = get_subugids(subgid_path)
print('Available subuids/subgids begin at %d/%d'% (next_uid_begin, next_gid_begin))

# Check consistency between /etc/subuid and /etc/subgid, which is required to excute the following lines.
if existing_users != existing_users2 or next_uid_begin != next_gid_begin:
    print('Inconsistent content:', subuid_path, subgid_path)
    exit(1)

# Add users to /etc/subuid and /etc/subgid
# Perhaps you should use $usermod command instead of editting directly.
id_incr = 65536
with open(subuid_path, mode='a') as subuid_file:
    for user in user_list:
        if user not in existing_users:
            if args.uid_maps is None:
                new_line = '%s:%d:%d' % (user, next_uid_begin, id_incr)
                subuid_file.write(new_line + '\n')
                next_uid_begin += id_incr
            else:
                current_id = next_uid_begin
                container_id = 0
                for map in args.uid_maps:
                    if map[1] - container_id - 1 > 0:
                        new_line = '%s:%d:%d' % (user, current_id, map[1] - container_id - 1)
                        subuid_file.write(new_line + '\n')
                    new_line = '%s:%d:%d' % (user, map[0], 1)
                    subuid_file.write(new_line + '\n')
                    current_id += map[1] - container_id
                    container_id = map[1]
                if current_id < next_uid_begin + id_incr:
                    new_line = '%s:%d:%d' % (user, current_id, next_uid_begin + id_incr - current_id)
                    subuid_file.write(new_line + '\n')
                    next_uid_begin += id_incr

with open(subgid_path, mode='a') as subgid_file:
    for user in user_list:
        if user not in existing_users:
            if args.gid_maps is None:
                new_line = '%s:%d:%d' % (user, next_gid_begin, id_incr)
                subgid_file.write(new_line + '\n')
                next_gid_begin += id_incr
            else:
                current_id = next_gid_begin
                container_id = 0
                for map in args.gid_maps:
                    if map[1] - container_id - 1 > 0:
                        new_line = '%s:%d:%d' % (user, current_id, map[1] - container_id - 1)
                        subgid_file.write(new_line + '\n')
                    new_line = '%s:%d:%d' % (user, map[0], 1)
                    subgid_file.write(new_line + '\n')
                    current_id += map[1] - container_id
                    container_id = map[1]
                if current_id < next_gid_begin + id_incr:
                    new_line = '%s:%d:%d' % (user, current_id, next_gid_begin + id_incr - current_id)
                    subgid_file.write(new_line + '\n')
                    next_gid_begin += id_incr

print('Added %d users' % len(user_list))
