#!/bin/bash

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    exit 1
fi

site_name="$1"

docker stop "$site_name"_wp
docker stop "$site_name"_db
docker rm "$site_name"_wp
docker rm "$site_name"_db
