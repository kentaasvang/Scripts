#!/bin/bash

#  check input
if [ $# -ne 1 ]; then
  echo "Usage: $0 <site_name>"
  exit 1
fi

SITE_NAME=$1

# *** check for installed dependecies ***

# Need wget to download the latest version of WordPress
DEPENDECIES="wget unzip mysql"

for DEP in $DEPENDECIES; do
  if ! [ -x "$(command -v $DEP)" ]; then
    echo "Error: $DEP is not installed." >&2
    exit 1
  fi
done

# *** Downloading wordpress ***
echo "Downloading the wordpress version 6.4.3"
wget https://wordpress.org/wordpress-6.4.3.zip

# *** Unzipping the wordpress ***
echo "Unzipping the wordpress"
unzip wordpress-6.4.3.zip

# *** Creating website folder
echo "Creating the website folder"
sudo mkdir -p /var/www/$SITE_NAME
sudo chown -R www-data:www-data /var/www/$SITE_NAME
sudo cp -r wordpress/* /var/www/$SITE_NAME  
