#!/bin/bash

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    echo "Example:  example example_21001010"
    exit 1
fi

site_name="$1"

# Check if archive_name is provided as an argument
if [ -z "$2" ]; then
    echo "Please provide the archive_name as an argument."
    echo "Example:  example example_21001010"
    exit 1
fi

archive_name="$2"

# Store the container IP in a variable
container_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$site_name"_db)

# MySQL root password (replace 'your_password' with your actual password)
mysql_password='root-password'

# Database name
db_name="$site_name"_db

#echo $container_ip

mysql -u root -h "$container_ip" -p"$mysql_password" "$db_name" < "$archive_name".sql

rm -r "$site_name"/html/*

unzip "$archive_name".zip -d "$site_name"/html

chown -R www-data:www-data "$site_name"/html
