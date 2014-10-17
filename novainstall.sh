#!/bin/sh
HOST_NAME="controller"
HOST_IP_ETH0="172.16.10.62"
HOST_IP_ETH1="10.0.0.62"
USERNAME="root"
PASSWORD="gh123321"

echo Install nova packages
apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth \
nova-novncproxy nova-scheduler python-novaclient
echo Install success!
echo

echo Create a Mysql database for Nova
mysql -u${USERNAME}  -p${PASSWORD} <<EOF
    CREATE DATABASE nova;
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'NOVA_DBPASS';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'NOVA_DBPASS';
    QUIT
EOF
echo Create a MySQL database success!
echo

echo Configure service user and role
keystone user-create --name=nova --pass=service_pass --email=nova@domain.com
keystone user-role-add --user=nova --tenant=service --role=admin
echo Configure success!
echo

echo Register the service and create the endpoint
keystone service-create --name=nova --type=compute --description="OpenStack Compute"
keystone endpoint-create \
--service-id=$(keystone service-list | awk '/ compute / {print $2}') \
--publicurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s \
--internalurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s \
--adminurl=http://$HOST_NAME:8774/v2/%\(tenant_id\)s
echo Register success!
echo

echo Edit the /etc/nova/nova.conf 
sed -i '/\[database\]/a\
connection = mysql://nova:NOVA_DBPASS@'"$HOST_NAME"'/nova' nova.conf
sed -i '/\[DEFAULT\]/a\
rpc_backend = rabbit\
rabbit_host = '"$HOST_NAME"'\
my_ip = '"$HOST_IP_ETH1"'\
vncserver_listen = '"$HOST_IP_ETH1"'\
vncserver_proxyclient_address = '"$HOST_IP_ETH1"'\
auth_strategy = keystone' nova.conf
sed -i '/\[keystone_authtoken\]/a\
auth_uri = http://'"$HOST_NAME"':5000\
auth_host = '"$HOST_NAME"'\
auth_port = 35357\
auth_protocol = http\
admin_tenant_name = service\
admin_user = nova\
admin_password = service_pass' nova.conf
echo Update success!
echo

echo Remove Nova SQLite database 
rm /var/lib/nova/nova.sqlite
echo Remove success!
echo

echo Synchronize your database
nova-manage db sync
echo Synchronize success!
echo

echo Restart nova-* services
service nova-api restart
service nova-cert restart
service nova-conductor restart
service nova-consoleauth restart
service nova-novncproxy restart
service nova-scheduler restart
echo Restart success!
echo

echo Check Nova is running
nova-manage service list
echo Check success!
echo

echo To verify your configuration, list available images
. /root/creds
nova image-list
echo List success!

echo Edit the /etc/nova/nova.conf 
sed -i '/\[DEFAULT\]/a\
network_api_class = nova.network.api.API\
security_group_api = nova' nova.conf
echo Edit success!
echo

echo Restart the Compute services
service nova-api restart
service nova-scheduler restart
service nova-conductor restart
echo Restart success!

