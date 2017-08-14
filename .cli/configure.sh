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
eval $(yamlParse config.yml)

# Validate config
requiredValues=(admin_username admin_password composer_version composer_command
    mysql_version mysql_port mysql_database nginx_version nginx_port php_version
    phpmyadmin_version phpmyadmin_port phpredmin_version phpredmin_port
    redis_version redis_port postgres_version postgres_database postgres_port
    pgweb_port pgweb_version memcached_version memcached_port
    memcached_memory_limit memcached_connection_limit memcached_threads
    memcached_max_requests_per_event memcached_listen_backlog
    memcached_max_item_size phpmemcachedadmin_port)
for i in "${requiredValues[@]}"
do
    if [ -z "${!i}" ]; then
        label="${i/_/:}"
        echo "config.yml invalid. Missing required value $label"
        exit 1
    fi
done

#todo: validate no matching ports

# Prepare configuration files
# - import must be relative to the calling icebt script, not this file.
. ./.cli/prepareConfigFile.sh
prepareConfigFile ./dist.env ./.env
prepareConfigFile nginx.conf
prepareConfigFile phpmemcachedadmin.conf.php
prepareConfigFile icemika.json
prepareConfigFile phpredmin.php
prepareConfigFile redis.conf

# All done
exit 0