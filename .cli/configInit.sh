#!/usr/bin/env bash

# Validate required files exist
requiredFiles=(./config.yml ./.env.dist ./env/.config/icemika.json.dist
    ./env/.config/nginx.conf.dist ./env/.config/phpredmin.php.dist)
for file in "${requiredFiles[@]}"
do
    if [ ! -f $file ]; then
        echo "Could not build iceBT. $file not found"
        exit 1
    fi
done

# Read config
#import must be relative to the calling icebt script, not this file.
. ./.cli/yamlParse.sh
eval $(yamlParse config.yml "c_")

# Validate config
requiredValues=(admin_username admin_password composer_version composer_command
 mysql_version mysql_port mysql_database nginx_version nginx_port php_version
 phpmyadmin_version phpmyadmin_port phpredmin_version phpredmin_port
 redis_version redis_port)
for i in "${requiredValues[@]}"
do
    key=c_$i
    if [ -z "${!key}" ]; then
        label="${i/_/:}"
        echo "config.yml invalid. Missing required value $label"
        exit 1
    fi
done

# Nginx config creation
# - Copy dist config into usable without overwriting if one already exists.
cp -n ./env/.config/nginx.conf.dist ./env/.config/nginx.conf

# .env token replacement
# - Replace configuration (config.yml) values into ./.env.dist saved to ./.env
sed -e "s/{@nginx\.version}/$c_nginx_version/g" \
    -e "s/{@nginx\.port}/$c_nginx_port/g" \
    -e "s/{@php\.version}/$c_php_version/g" \
    -e "s/{@composer\.version}/$c_composer_version/g" \
    -e "s/{@composer\.command}/$c_composer_command/g" \
    -e "s/{@mysql\.version}/$c_mysql_version/g" \
    -e "s/{@mysql\.port}/$c_mysql_port/g" \
    -e "s/{@mysql\.rootpassword}/$c_mysql_root_password/g" \
    -e "s/{@mysql\.database}/$c_mysql_database/g" \
    -e "s/{@admin\.username}/$c_admin_username/g" \
    -e "s/{@admin\.password}/$c_admin_password/g" \
    -e "s/{@phpmyadmin\.version}/$c_phpmyadmin_version/g" \
    -e "s/{@phpmyadmin\.port}/$c_phpmyadmin_port/g" \
    -e "s/{@redis\.version}/$c_redis_version/g" \
    -e "s/{@redis\.port}/$c_redis_port/g" \
    -e "s/{@phpredmin\.version}/$c_phpredmin_version/g" \
    -e "s/{@phpredmin\.port}/$c_phpredmin_port/g" \
     ./.env.dist > ./.env

#icemika.json token replacement
# - Replace configuration (config.yml) values into ./env/config/icemika.json.dist
#   saved to ./env/config/icemika.json
sed -e "s/{@mysql\.database}/$c_mysql_database/g" \
    -e "s/{@admin\.username}/$c_admin_username/g" \
    -e "s/{@admin\.password}/$c_admin_password/g" \
    ./env/.config/icemika.json.dist > ./env/.config/icemika.json

# phpredmin.php token replacement
# - Replace configuration (config.yml) values into ./env/config/phpredmin.php.dist
#   saved to ./env/config/phpredmin.php
sed -e "s|{@phpredmin\.timezone}|$c_phpredmin_timezone|g" \
    -e "s/{@admin\.username}/$c_admin_username/g" \
    -e "s/{@admin\.password}/$c_admin_password/g" \
    ./env/.config/phpredmin.php.dist > ./env/.config/phpredmin.php

exit 0