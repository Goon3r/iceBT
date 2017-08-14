#!/usr/bin/env bash

# Prepares a configuration file
#
# The following function will replace all available tokens with the
# corresponding value as, remove both bash '#' and PHP '/* */' comments
# and clear any empty lines.
#
# Note: For this function to work correctly it is required that the config.yml
# file has been parsed and the variables from it available. To do this run
# the following in the script that leverage this command/function:
# $ . ./.cli/yamlParse.sh
# $ eval $(yamlParse config.yml)
# It is important that a prefix is not provided when parsing the yaml file, if
# a prefix is provided the variables created will not match those defined here.
#
# This command has two usages as defined below.
#
# Clean a known file and save to a specific location
#     Command:
#         $ configPrepare source.file prepared.file
#     Arguments:
#         original file - The path to the file to prepare/clean
#         new file path - The path to save the prepared/cleaned file to
#
# Prepare an environment config file
#     Command:
#         $ configPrepare base.file
#     Arguments:
#         base file - The name of the base file to prepare
#     Comments:
#         The base file passed to this argument represents the 'final' config
#         file's name. A 'final' config file is a distributed config file that
#         has been duplicated and had the 'dist.' prefix removed from it. If
#         the passed 'final' config file could not be found the distributed
#         file is used.
#
#         When using the command in this manor both the source and destination
#         path are assumed to be within the ./env/config and ./env/config/.prod
#         directories respectively.
#
#         An example, would be to prepare the dist.nginx.conf file pass
#         nginx.conf as an argument, if dist.nginx.conf has been duplicated
#         and updated and saved to nginx.conf it will be used, if not the dist.
#         version will be.
prepareConfigFile() {
    if [ -z $2 ]; then
        filePath="./env/config/"
        fileName=$1

        destPath="./env/config/.prod"
        dest=$destPath"/"$fileName

        if [ ! -d $destPath ]; then
            mkdir -p $destPath
        fi

        # Detemine the source file, is it the original dist file or a copied
        # updated file.
        if [ ! -f $filePath$fileName ]; then
            source=$filePath"dist."$fileName;
        else
            source=$filePath$fileName;
        fi
    else
        source=$1
        dest=$2
    fi

    # Double check the source exists before processing
    if [ ! -f $source ]; then
        echo Could not prepare $1 config. Source could not be found at: $source
        exit 1
    fi

    sed -e "s/{@nginx\.version}/$nginx_version/g" \
        -e "s/{@nginx\.port}/$nginx_port/g" \
        -e "s/{@php\.version}/$php_version/g" \
        -e "s/{@composer\.version}/$composer_version/g" \
        -e "s/{@composer\.command}/$composer_command/g" \
        -e "s/{@mysql\.version}/$mysql_version/g" \
        -e "s/{@mysql\.port}/$mysql_port/g" \
        -e "s/{@mysql\.rootpassword}/$mysql_root_password/g" \
        -e "s/{@mysql\.database}/$mysql_database/g" \
        -e "s/{@admin\.username}/$admin_username/g" \
        -e "s/{@admin\.password}/$admin_password/g" \
        -e "s/{@phpmyadmin\.version}/$phpmyadmin_version/g" \
        -e "s/{@phpmyadmin\.port}/$phpmyadmin_port/g" \
        -e "s/{@redis\.version}/$redis_version/g" \
        -e "s/{@redis\.port}/$redis_port/g" \
        -e "s/{@phpredmin\.version}/$phpredmin_version/g" \
        -e "s/{@phpredmin\.port}/$phpredmin_port/g" \
        -e "s/{@postgres\.version}/$postgres_version/g" \
        -e "s/{@postgres\.database}/$postgres_database/g" \
        -e "s/{@postgres\.port}/$postgres_port/g" \
        -e "s/{@pgweb\.port}/$pgweb_port/g" \
        -e "s/{@pgweb\.version}/$pgweb_version/g" \
        -e "s/{@memcached\.version}/$memcached_version/g" \
        -e "s/{@memcached\.port}/$memcached_port/g" \
        -e "s/{@memcached\.memory_limit}/$memcached_memory_limit/g" \
        -e "s/{@memcached\.connection_limit}/$memcached_connection_limit/g" \
        -e "s/{@memcached\.threads}/$memcached_threads/g" \
        -e "s/{@memcached\.max_requests_per_event}/$memcached_max_requests_per_event/g" \
        -e "s/{@memcached\.listen_backlog}/$memcached_listen_backlog/g" \
        -e "s/{@memcached\.max_item_size}/$memcached_max_item_size/g" \
        -e "s/{@phpmemcachedadmin\.port}/$phpmemcachedadmin_port/g" \
        -e "s/#.*$//" \
        -e "s|\/\*.*\*\/||g" $source > $dest
    sed -i '' -e "/^[[:space:]]*$/d" $dest
}

