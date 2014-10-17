#!/bin/sh
HOST_NAME="controller"
HOST_IP_ETH0="172.16.10.62"

echo Install the required packages
apt-get install -y apache2 memcached libapache2-mod-wsgi openstack-dashboard
echo Install success!
echo

echo Remove the openstack-dashboard-ubuntu-theme package
apt-get remove -y --purge openstack-dashboard-ubuntu-theme
echo Remove success!
echo

echo Edit /etc/openstack-dashboard/local_settings.py
sed -i 's/OPENSTACK_HOST = "controller"/OPENSTACK_HOST = "controller1"/g' local_settings.py
echo Edit success!
echo

echo Reload Apache and memcached
service apache2 restart; service memcached restart
echo Reload success!
