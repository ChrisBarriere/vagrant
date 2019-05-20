echo "nameserver 192.168.137.1
search $1" | sudo resolvconf -a eth0.inet
