#!/usr/bin/env bash

# Validate required files exist
requiredFiles=(./config.yml ./dist.env ./env/config/dist.icemika.json
    ./env/config/dist.nginx.conf ./env/config/dist.phpredmin.php
    ./env/config/dist.redis.conf ./env/config/dist.phpmemcachedadmin.conf.php)
for file in "${requiredFiles[@]}"
do
    if [ ! -f $file ]; then
        echo "Could not build iceBT. $file not found"
        if [ $file == "./config.yml" ]; then
            echo "To generate a config file run: ./icebt config-init"
        fi
        exit 1
    fi
done

# Read config
# - import must be relative to the calling icebt script, not this file.
. ./.cli/yamlParse.sh
eval $(yamlParse config.yml "c_")

# Validate config
requiredValues=(admin_username admin_password composer_version composer_command
    mysql_version mysql_port mysql_database nginx_version nginx_port php_version
    phpmyadmin_version phpmyadmin_port phpredmin_version phpredmin_port
    redis_version redis_port postgres_version postgres_database postgres_port
    pgweb_port pgweb_version memcached_version memcached_port
    phpmemcachedadmin_port)
for i in "${requiredValues[@]}"
do
    key=c_$i
    if [ -z "${!key}" ]; then
        label="${i/_/:}"
        echo "config.yml invalid. Missing required value $label"
        exit 1
    fi
done

#todo: validate no matching ports

# Import config prepare/tokenizing command
# - import must be relative to the calling icebt script, not this file.
. ./.cli/configPrepare.sh

# .env file config creation
configPrepare ./dist.env ./.env

# Nginx config creation
# - If config file doesnt already exist, copy over remove blanks and comments
configPrepare nginx.conf
# PHPMemcachedAdmin config creation
configPrepare phpmemcachedadmin.conf.php

# iceMika config creation
configPrepare icemika.json

# PHPRedMin config creation
configPrepare phpredmin.php

# Redis config creation
configPrepare redis.conf

# All done
exit 0