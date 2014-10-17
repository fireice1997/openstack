#!/bin/sh
HOST_NAME="controller"
HOST_IP_ETH0="172.16.10.62"
HOST_IP_ETH1="10.0.0.62"
USERNAME="root"
PASSWORD="gh123321"

echo apt-get install -y keystone 
#apt-get install -y keystone
echo keystone install success!
echo

echo create mysql database 
#mysql -u${USERNAME}  -p${PASSWORD} <<EOF
#    CREATE DATABASE keystone;
#    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';
#    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_DBPASS';
#    QUIT
#EOF
echo mysql operation success!
echo

echo rm /var/lib/keystone/keystone.db
#rm /var/lib/keystone/keystone.db
echo rm keystone.db success!
echo

echo edit keystone.conf
#sed -i 's#connection = sqlite:////var/lib/keystone/keystone.db#connection = mysql://keystone:KEYSTONE_DBPASS@'"$HOST_NAME"'/keystone#g' keystone.conf
#sed -i '/\[DEFAULT\]/a\
#admin_token=ADMIN\
#log_dir=\/var\/log\/keystone' keystone.conf
echo edit keystone.conf success!
echo

echo sync keystone
#service keystone restart
#keystone-manage db_sync
echo keystone db_sync success!
echo

echo check synchronization
mysql -u${USERNAME}  -p${PASSWORD} <<EOF
    use keystone
    show TABLES;
    QUIT
EOF
echo Check synchronization success!
echo

echo Define users, tenants, and roles
#export OS_SERVICE_TOKEN=ADMIN
#export OS_SERVICE_ENDPOINT=http://$HOST_NAME:35357/v2.0
#keystone user-create --name=admin --pass=admin_pass --email=admin@domain.com
#keystone role-create --name=admin
#keystone tenant-create --name=admin --description="Admin Tenant"
#keystone user-role-add --user=admin --tenant=admin --role=admin
#keystone user-role-add --user=admin --role=_member_ --tenant=admin
#keystone user-create --name=demo --pass=demo_pass --email=demo@domain.com
#keystone tenant-create --name=demo --description="Demo Tenant"
#keystone user-role-add --user=demo --role=_member_ --tenant=demo
#keystone tenant-create --name=service --description="Service Tenant"
echo Define users, tenants, and roles success!
echo

echo Define services and API endpoints 
#keystone service-create --name=keystone --type=identity --description="OpenStack Identity"
#keystone endpoint-create \
#--service-id=$(keystone service-list | awk '/ identity / {print $2}') \
#--publicurl=http://$HOST_IP_ETH0:5000/v2.0 \
#--internalurl=http://$HOST_NAME:5000/v2.0 \
#--adminurl=http://$HOST_NAME:35357/v2.0
echo Define services and API endpoints success!
echo

echo Create a simple credential file
echo "export OS_TENANT_NAME=admin" > creds1
sed -i '$a\
export OS_USERNAME=admin\
export OS_PASSWORD=admin_pass\
export OS_AUTH_URL=http://'"$HOST_IP_ETH0"':5000/v2.0' creds1
 
echo "export OS_USERNAME=admin" > admin_creds1
sed -i '$a\
export OS_PASSWORD=admin_pass\
export OS_TENANT_NAME=admin\
export OS_AUTH_URL=http://'"$HOST_NAME"':35357/v2.0' admin_creds1
echo Create a simple credential file success!
echo

echo Test Keystone
unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT
keystone --os-username=admin --os-password=admin_pass --os-auth-url=http://$HOST_NAME:35357/v2.0 token-get
. /root/admin_creds
keystone token-get
. /root/creds
keystone user-list
keystone user-role-list --user admin --tenant admin
echo Test Keystone success!
echo

