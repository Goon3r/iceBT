#!/usr/bin/env bash

# Parses a yaml file into bash variables.
#
# The following function will convert the contents of a yaml file into bash
# variables with each indentation represented as an underscore (_) in the
# variable name.
#
# Arguments:
#     source file - The path of the file to parse (relative/absolute)
#     prefix      - String to prefix created variables with
#
# Example:
#     @file file.yml
#     mysql:
#         user: root
#         pass: root
#
#     @bash
#     yamlParse file.yml prefix_with_
#
#     echo $prefix_with_mysql_user | root
yamlParse() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/7;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}