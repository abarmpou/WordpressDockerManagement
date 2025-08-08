#!/bin/bash

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    echo "Example:  dea"
    exit 1
fi

site_name="$1"

# Store the container IP in a variable
container_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$site_name"_db)

# MySQL root password (replace 'your_password' with your actual password)
mysql_password='root-password'

# Database name
db_name="$site_name"_db

#echo $container_ip

current_date=$(date +"%Y%m%d")  # Get the current date in the desired format


# Log in to MySQL with password and select the database
mysqldump --add-drop-table -u root -h "$container_ip" -p"$mysql_password" "$db_name" > "$site_name"_"$current_date".sql

cd "$site_name"/html || exit 1  # Navigate into the directory or exit if it fails

zip -r "../../${site_name}_${current_date}.zip" .  # Create the zip file from the current directory contents

cd - >/dev/null  # Return to the previous directory (optional)
