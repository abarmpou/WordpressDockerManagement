#!/bin/bash

# Setup swap memory
sudo fallocate -l 1G /swapfile  # Allocate 1GB of disk space
sudo chmod 600 /swapfile       # Set the correct permissions
sudo mkswap /swapfile          # Format the file as swap space
sudo swapon /swapfile          # Enable the swap file
/swapfile none swap sw 0 0    # Make it permanent

# Install components
sudo apt update
sudo apt install mariadb-client
sudp apt install apache2
sudo apt install certbot python3-certbot-apache

# Enable apache mods
sudo a2enmod headers
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2enmod rewrite
sudo a2enmod ssl
sudo systemctl restart apache2




