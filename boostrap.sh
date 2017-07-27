#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

chef_version='12.15.8'
rpm_package="chef-server-core-$chef_version-1.el7.x86_64.rpm"
rpm_url="https://packages.chef.io/files/stable/chef-server/$chef_version/el/7/$rpm_package"


# 0 - fetch Chef server RPM

[ -f "./$rpm_package" ] || curl -LO "$rpm_url"


# 1 - setup virtual machines

vagrant status | grep -q running || vagrant up


# 2 - obtain private key for "admin" user

vagrant ssh-config > ./.ssh_config
ssh -F ./.ssh_config chef-server cat admin.pem > ./.chef/admin.pem


# 3 - obtain TLS certificates from Chef server

rm -rfv .chef/trusted_certs && knife ssl fetch && knife ssl check


# 4 - fetch and upload the 'chef-client' cookbook and it's dependencies to
#     chef-server

cat > ./Berksfile <<-'EOF'
source 'https://supermarket.chef.io'
cookbook 'chef-client'
EOF
berks install
SSL_CERT_FILE='./.chef/trusted_certs/chef-server.crt' berks upload


# 5 - create a 'base' role with 'chef-client' cookbook recipes in it's run_list

mkdir -pv ./roles
cat > ./roles/base.json <<-'EOF'
{
   "name": "base",
   "description": "Base role",
   "json_class": "Chef::Role",
   "default_attributes": {
     "chef_client": {
       "interval": 300,
       "splay": 60
     }
   },
   "override_attributes": {
   },
   "chef_type": "role",
   "run_list": [
        "recipe[chef-client::default]",
        "recipe[chef-client::delete_validation]"
   ],
   "env_run_lists": {
   }
}
EOF


# 6 - upload 'base' role to chef-server

knife role from file ./roles/base.json


# 7 - bootstrap all the nodes

for node in node-1 node-2 node-3; do
  knife bootstrap "$node" \
    --ssh-user vagrant \
    --sudo \
    --identity-file "./.vagrant/machines/$node/libvirt/private_key" \
    --run-list 'role[base]' \
    --node-name "$node" 
done


# 8 - display status

knife status role:base --run-list
