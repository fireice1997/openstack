#!/bin/sh
HOST_NAME="controller"
HOST_IP_ETH0="172.16.10.62"
IMAGE_NAME="cirros-0.3.2-x86_64"
IMAGE_PATH="/root/cirros-0.3.2-x86_64-disk.img"
USERNAME="root"
PASSWORD="gh123321"

echo apt-get install -y glance python-glanceclient
apt-get install -y glance python-glanceclient
echo Install success!
echo

echo Create a MySQL database for Glance
mysql -u${USERNAME}  -p${PASSWORD} <<EOF
    CREATE DATABASE glance;
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE _DBPASS';
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'GLANCE_DBPASS';
    QUIT
EOF
echo Create a MySQL database success!
echo

echo Configure service user and role
keystone user-create --name=glance --pass=service_pass --email=galnce@domain.com
keystone user-role-add --user=glance --tenant=service --role=admin
echo Configure success!
echo

echo Register the service and create the endpoint
keystone service-create --name=glance --type=image --description="OpenStack Image Service"
keystone endpoint-create \
--service-id=$(keystone service-list | awk '/ image / {print $2}') \
--publicurl=http://$HOST_IP_ETH0:9292 \
--internalurl=http://$HOST_NAME:9292 \
--adminurl=http://$HOST_NAME:9292
echo Register success!
echo

echo Update /etc/glance/glance-api.conf 
sed -i 's#sqlite_db = /var/lib/glance/glance.sqlite#connection = mysql://glance:GLANCE_DBPASS@'"$HOST_NAME"'/glance#g' glance-api.conf
sed -i '1 a\
rpc_backend = rabbit\
rabbit_host = controller' glance-api.conf
sed -i '/\[keystone_authtoken\]/a\
auth_uri = http://'"$HOST_NAME"':5000\
auth_host = '"$HOST_NAME"'\
auth_port = 35357\
auth_protocol = http\
admin_tenant_name = service\
admin_user = glance\
admin_password = service_pass' glance-api.conf
sed -i '/\[paste_deploy\]/a\
flavor = keystone ' glance-api.conf
echo Update success!
echo

echo Update /etc/glance/glance-registry.conf
sed -i 's#sqlite_db = /var/lib/glance/glance.sqlite#connection = mysql://glance:GLANCE_DBPASS@'"$HOST_NAME"'/glance#g' glance-registry.conf
sed -i '/\[keystone_authtoken\]/a\
auth_uri = http://'"$HOST_NAME"':5000\
auth_host = '"$HOST_NAME"'\
auth_port = 35357\
auth_protocol = http\
admin_tenant_name = service\
admin_user = glance\
admin_password = service_pass' glance-registry.conf
sed -i '/\[paste_deploy\]/a\
flavor = keystone ' glance-registry.conf
echo Update success!
echo

echo Restart the glance-api and glance-registry services
service glance-api restart; service glance-registry restart
echo Restart success!
echo

echo glance-manage db_sync
glance-manage db_sync
echo Synchronize the glance database success!
echo

echo Test Glance, upload the cirros cloud image
. /root/creds
glance image-create --name "$IMAGE_NAME" --is-public true \
--container-format bare --disk-format qcow2 \
--file $IMAGE_PATH
echo upload success!
echo

echo List Images
glance image-list
echo List success!
