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
    exit 1
fi

site_name="$1"

# Check if url_option is not empty
if [ -n "$url_option" ]; then
    echo "URL: $url_option"
    # Add your logic here based on the condition
else
    url_option="https://research.dwi.ufl.edu/projects/$site_name"
    echo "URL: $url_option"
    # Add logic for the case when the option is empty
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing docker..."
    apt-get update
    apt-get install docker
# The following line may be needed if you get an installation error message
#    apt-get install containerd=1.3.3-0ubuntu2
    apt install docker.io
    docker --version
fi

# Define the image name
image_name="mariadb"

# Check if the Docker image exists
if docker images "$image_name" | grep "$image_name" >/dev/null; then
    echo "The Docker image '$image_name' exists. Checking for updates..."
    docker pull "$image_name:latest"
else
    echo "The Docker image '$image_name' does not exist. Pulling image..."
    docker pull "$image_name:latest"
fi

# Define the image name
image_name="wordpress"

# Check if the Docker image exists
if docker images "$image_name" | grep "$image_name" >/dev/null; then
    echo "The Docker image '$image_name' exists. Checking for updates..."
    docker pull "$image_name:latest"
else
    echo "The Docker image '$image_name' does not exist. Pulling image..."  
    docker pull "$image_name:latest"
fi

# Check if a local folder with the site_name exists
if [ -d "$site_name" ]; then
    echo "A local folder with the name '$site_name' exists. Please remove it."
    exit 1
else
    echo "Creating local folder '$site_name'..."
    mkdir -p "$site_name"/{html,database}
fi

port=8101
port_found=false

while [ "$port_found" = false ] && [ "$port" -lt 8200 ]; do
    if docker ps | grep ":$port" >/dev/null; then
        port=$((port + 1))
    else
        port_found=true
    fi
done

if [ "$port_found" = false ]; then
    echo "No available ports found in the range."
else
    echo "Available port: $port"
fi

current_directory=$(pwd)


docker run -e MYSQL_ROOT_PASSWORD=root-password -e MYSQL_USER="$site_name"_user -e MYSQL_PASSWORD=password -e MYSQL_DATABASE="$site_name"_db -v "$current_directory"/"$site_name"/database:/var/lib/mysql --name "$site_name"_db -d --restart unless-stopped mariadb

container_ip=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' "$site_name"_db)
echo "The IP address of the container ${site_name}_db is: $container_ip"

docker run -e WORDPRESS_DB_USER="$site_name"_user -e WORDPRESS_DB_PASSWORD=password -e WORDPRESS_DB_NAME="$site_name"_db -p "$port":80 -v "$current_directory"/"$site_name"/html:/var/www/html --link "$site_name"_db:mysql --name "$site_name"_wp -d --restart unless-stopped wordpress:latest

#wordpress:5.0.0 is helpful for migrating an old site


required_files=(
  "$site_name/html/index.php"
  "$site_name/html/wp-config-sample.php"
  "$site_name/html/wp-login.php"
  "$site_name/html/wp-admin"
  "$site_name/html/wp-includes"
  "$site_name/html/wp-content"
)

echo "Waiting for WordPress files to be ready..."

while true; do
    all_present=true
    for f in "${required_files[@]}"; do
        if [ ! -e "$f" ]; then
            all_present=false
            break
        fi
    done

    if [ "$all_present" = true ]; then
        echo "All WordPress core files are present."
        break
    else
        echo "Still waiting for WordPress files..."
        sleep 3
    fi
done

chown -R www-data:www-data "$site_name"/html

# Extracting path after the domain
path=$(echo "$url_option" | sed 's|^[^/]*//[^/]*\(.*\)|\1|')

if [[ $path == /* ]]; then
    path="${path#"/"}"  # Remove the leading /
fi

# Check if url_option is not empty
if [ -n "$path" ]; then
    if [[ ! $path == */ ]]; then
        path="$path/"  # Add / at the end
    fi
    echo "WP installation at the path: $path"
else
    echo "WP installation at the root of the domain"
    exit 0
fi

mkdir -p "$site_name"/html2/"$path"
cp -r "$site_name"/html/* "$site_name"/html2/"$path"
rm -r "$site_name"/html
mv "$site_name"/html2 "$site_name"/html

echo "RewriteEngine On" > "$site_name"/html/"$path".htaccess
echo "RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]" >> "$site_name"/html/"$path".htaccess
echo "RewriteBase /$path" >> "$site_name"/html/"$path".htaccess
echo "RewriteRule ^index\.php$ - [L]" >> "$site_name"/html/"$path".htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> "$site_name"/html/"$path".htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> "$site_name"/html/"$path".htaccess
echo "RewriteRule . /${path}index.php [L]" >> "$site_name"/html/"$path".htaccess

chown -R www-data:www-data "$site_name"/html

docker stop "$site_name"_wp
docker start "$site_name"_wp


echo "You are all set!"
echo "Make sure you add to your Apache2 conf file the lines:"
echo ""
echo "RequestHeader set X-Forwarded-Proto \"https\""
echo "RequestHeader set X-Forwarded-Port \"443\""
echo "ProxyPass /projects/$site_name/ http://localhost:$port/projects/$site_name/"
echo "ProxyPassReverse /projects/$site_name/ http://localhost:$port/projects/$site_name/"
echo "ProxyPreserveHost On"
