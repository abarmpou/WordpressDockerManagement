#!/bin/bash

# Setup swap memory
sudo fallocate -l 1G /swapfile  # Allocate 1GB of disk space
sudo chmod 600 /swapfile       # Set the correct permissions
sudo mkswap /swapfile          # Format the file as swap space
sudo swapon /swapfile          # Enable the swap file
/swapfile none swap sw 0 0    # Make it permanent

# Install components
sudo apt -y update
sudo apt -y install mariadb-client
sudp apt -y install apache2
sudo apt -y install certbot python3-certbot-apache
sudo apt -y install git

# Enable apache mods
sudo a2enmod headers
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2enmod rewrite
sudo a2enmod ssl
sudo systemctl restart apache2

sudo mkdir /data
sudo mkdir /data/sites

#Other things you may want to do:
#git pull https://github.com/abarmpou/WordpressDockerManagement.git
#copy keys into /root/.ssh/
#sudo certbot --apache --register-unsafely-without-email

