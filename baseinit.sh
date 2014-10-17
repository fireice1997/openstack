#!/bin/sh
HOST_IP_ETH1="10.0.0.62"

echo "Update and Upgrade your System" 
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
echo update success!
echo

echo Install NTP service
apt-get install -y ntp
echo install ntp success!
echo

echo Install MySQL
apt-get install -y mysql-server python-mysqldb
echo install mysql success!
echo

echo Set the my.cnf 
sed -i '/# localhost which is more compatible and is not less secure./a\bind-address = '"$HOST_IP_ETH1"'' /etc/mysql/my.cnf
sed -i -f mysqlsed.txt /etc/mysql/my.cnf
echo Edit my.cnf success!
echo

echo Restart the MySQL service
service mysql restart
echo Restart success!
echo

echo mysql set
mysql_install_db
mysql_secure_installation
echo mysql set success!
echo

echo Install RabbitMQ
apt-get install -y rabbitmq-server
echo install success!
echo
