#!/bin/sh
HOST_NAME="gh-controller"
HOST_NAME_Compute="gh-compute1"
HOST_IP_ETH0="172.16.10.62"
HOST_IP_ETH1="10.0.0.62"
HOST_IP_Computer="10.0.0.63"
GATEWAY="172.16.10.1"
DNS_NAMESERVERS="172.16.10.1"

sed -i '$d' test1
echo "$HOST_NAME">test1
cat test1
echo Set the hostname success!

sed -i 's/dhcp/static/g' test
sed -i '$a\
address '"$HOST_IP_ETH0"'\
netmask 255.255.255.0\
gateway '"$GATEWAY"'\
dns-nameservers '"$DNS_NAMESERVERS"'\
auto eth1\
iface eth1 inet static\
address '"$HOST_IP_ETH1"'\
netmask 255.255.255.0' test
cat test
echo Edit network settings success!


sed -i '2 a\
'"$HOST_IP_ETH1"'     '"$HOST_NAME"'\
'"$HOST_IP_Computer"'     '"$HOST_NAME_Compute"'' hostsbak
cat hostsbak
echo Edit hosts success!

reboot

