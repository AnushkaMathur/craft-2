#!/bin/sh
apt-get update -y
apt-get install -y \
        mysql-server \
        nginx \
        php7.2-curl \
        php7.2-fpm \
        php7.2-gd \
        php7.2-mysql \
        php7.2-mbstring\
        php7.2-xml\
        php7.2-xmlrpc\
        php7.2-soap\
        php7.2-intl\
        php7.2-zip
systemctl restart php7.2-fpm
systemctl restart nginx


cd /var/www/html
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rm -rf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress
chown -R www-data:www-data /var/www/html/
chmod -R 775 /var/www/html

systemctl restart nginx
