#!/bin/bash

# ask inputs
read -p "Enter the site name: " SITE_NAME
echo $SITE_NAME

# *** check for installed dependecies ***
# Need wget to download the latest version of WordPress
DEPENDECIES="wget unzip mysql"
echo "Checking for installed dependecies"
for DEP in $DEPENDECIES; do
  if ! [ -x "$(command -v $DEP)" ]; then
    echo "Error: $DEP is not installed." >&2
    exit 1
  fi
done
echo "All dependecies are installed"


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

# clean up
rm -rf wordpress-6.4.3.zip wordpress

# *** Creating Nginx configuration file
echo "Creating Nginx configuration file"
sudo cp templates/nginx.default.conf /etc/nginx/sites-available/$SITE_NAME
sudo sed -i "s/<SITE_NAME>/$SITE_NAME/g" /etc/nginx/sites-available/$SITE_NAME

# testing the configuration, exiting if there is an error
sudo nginx -t
if [ $? -ne 0 ]; then
  echo "Error: Nginx configuration file is not valid"
  exit 1
fi
