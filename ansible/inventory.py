#!/usr/bin/env python

"""
The script is ugly, doesn't catch exceptions, there is no error handling
and could be used only for test exercise.
Was tested on Ubuntu 20.04 servers in DigitalOcean environment.

It is possible to define inventory groups for ansible when droplet has tag "ansible_group_mygroup".
Host will be added automatically to group "mygroup" in dynamic inventoy.

It is also possible to define ansible vars on invenrtory level adding tags like:
"ansible_var_foo:bar"
In this case for specific host will be defined variable "foo" with value "bar"
"""




import requests
import json
import os
from ipaddress import ip_network, ip_address

# the servers were created by terraform with specific tags to allow easily manage droplets with ansible
ansible_group_prefex = "ansible_group_"
ansible_var_prefex = "ansible_var_"

# default empty inventory
inventory = {
    'all': {
        'hosts': [],
        'vars': {}
    },
    '_meta': {'hostvars': {}}
}

# connection settings
api_token = os.environ.get('DIGITALOCEAN_TOKEN')
api_endpoint = 'https://api.digitalocean.com/v2/droplets'
request_timeout = 60
request_headers = {'Authorization': 'Bearer {0}'.format(api_token),
                   'Content-type': 'application/json'}

r = requests.get(api_endpoint, headers=request_headers, timeout=request_timeout)
r_json = json.loads(r.text)

for droplet in r_json["droplets"]:
  droplet_settings = {
    'hostname': '',
    'public_ip': '',
  }

  for tag in droplet["tags"]:

    # define key (ip address)
    for net in droplet['networks']['v4']:
      # print(net)
      if net['type'] == 'public':
        droplet_settings['public_ip'] = net['ip_address']
      else:
        continue

    # groups
    if ansible_group_prefex in tag:
      droplet_settings['hostname'] = droplet['name']
      inventory['all']['hosts'].append(droplet_settings['public_ip'])

      # if not isinstance(inventory['_meta']['hostvars'][droplet_settings['public_ip']], dict):
      inventory['_meta']['hostvars'][droplet_settings['public_ip']] = dict()

      inventory['_meta']['hostvars'][droplet_settings['public_ip']].update({
          "hostname": droplet_settings['hostname']
      })

      group = tag.replace(ansible_group_prefex, '')
      if group not in inventory:
        inventory[group] = dict()
        inventory[group]['hosts'] = list()

      inventory[group]['hosts'].append(droplet_settings['public_ip'])

    # vars
    if ansible_var_prefex in tag:
      tag_cleaned = tag.replace(ansible_var_prefex, '').split(':')
      if len(tag_cleaned) == 2:
        if isinstance(inventory['_meta']['hostvars'][droplet_settings['public_ip']], dict) == False:
          inventory['_meta']['hostvars'][droplet_settings['public_ip']] = dict()

        inventory['_meta']['hostvars'][droplet_settings['public_ip']].update({
            tag_cleaned[0]: tag_cleaned[1]
        })

print(json.dumps(inventory))
