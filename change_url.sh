#!/bin/bash


# Process command-line options
while getopts "u:" opt; do
    case $opt in
        u) url_option="$OPTARG";;
        *) echo "Invalid option"; exit 1;;
    esac
done

shift $((OPTIND - 1))

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    echo "Example: -u https://www.example.com example"
    exit 1
fi

site_name="$1"

# Check if url_option is not empty
if [ -n "$url_option" ]; then
    echo "URL: $url_option"
else
    echo "Please provide the site_name as an argument."
    echo "Example: -u https://www.example.com example"
    exit 1
fi

# Store the container IP in a variable
container_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$site_name"_db)

# MySQL root password (replace 'your_password' with your actual password)
mysql_password='password'

# Database name
db_name="$site_name"_db

#echo $container_ip

# Log in to MySQL with password and select the database
mysql -u "$site_name"_user -h "$container_ip" -p"$mysql_password" -e "USE $db_name;UPDATE wp_options SET option_value=\"$url_option\" WHERE option_name = \"home\";UPDATE wp_options SET option_value=\"$url_option\" WHERE option_name = \"siteurl\";SELECT * FROM wp_options WHERE option_name = 'home';SELECT * FROM wp_options WHERE option_name = 'siteurl';"

