#!/bin/bash

# update for name resolution
echo "nameserver 192.168.137.1
search $1" | sudo resolvconf -a eth0.inet

# installing pip and ansible
sudo apt-get update
sudo apt-get install -y python-pip
if [ "$2" == "DIRECT" ]; then
  pip install --upgrade ansible==2.8.0
else
  http_proxy="$2" https_proxy="$2" pip install --upgrade ansible==2.8.0
fi
