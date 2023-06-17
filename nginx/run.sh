#!/usr/bin/bash

if [ ! -e /var/www/nextcloud/config/config.php ];then
echo "<?php
\$CONFIG = array (
);" >/var/www/nextcloud/config/config.php
fi

if [ $(grep default_phone_region /var/www/nextcloud/config/config.php |wc -l) -eq 0 ];then
    sed -i.old -e "/^\$CONFIG/a 'default_phone_region' =>'JP'," /var/www/nextcloud/config/config.php
fi

exec nginx -c /etc/nginx/nginx_user.conf
