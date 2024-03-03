#!/bin/bash

# ask inputs
read -p "Enter the site name: " SITE_NAME
read -p "Create site folder? (y/n): " CREATE_SITE_FOLDER
read -p "Configure Nginx? (y/n): " CONFIGURE_NGINX
read -p "Configure MySQL? (y/n): " CONFIGURE_MYSQL

# if CREATE_SITE_FOLDER is not "y" or "Y"
if [ "$CREATE_SITE_FOLDER" != "y" ] && [ "$CREATE_SITE_FOLDER" != "Y" ]; then
  CREATE_SITE_FOLDER=0
else
  CREATE_SITE_FOLDER=1
fi

# if CONFIGURE_MYSQL is not "y" or "Y"
if [ "$CONFIGURE_MYSQL" != "y" ] && [ "$CONFIGURE_MYSQL" != "Y" ]; then
  CONFIGURE_MYSQL=0
else
  CONFIGURE_MYSQL=1
fi

# if CONFIGURE_NGINX is not "y" or "Y"
if [ "$CONFIGURE_NGINX" != "y" ] && [ "$CONFIGURE_NGINX" != "Y" ]; then
  CONFIGURE_NGINX=0
else
  CONFIGURE_NGINX=1
fi

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

if [ $CREATE_SITE_FOLDER -eq 1 ]; then

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
  sudo -u www-data cp /var/www/$SITE_NAME/wp-config-sample.php /var/www/$SITE_NAME/wp-config.php

  # clean up
  rm -rf wordpress-6.4.3.zip wordpress

fi

if [ $CONFIGURE_NGINX -eq 1 ]; then

  # *** Creating Nginx configuration file
  echo "Creating Nginx configuration file"
  sudo cp templates/nginx/default.conf /etc/nginx/sites-available/$SITE_NAME
  sudo sed -i "s/<SITE_NAME>/$SITE_NAME/g" /etc/nginx/sites-available/$SITE_NAME

  # Test the Nginx configuration
  output=$(sudo nginx -t 2>&1)

  # Check for the word 'error' or 'warn' in the output
  if echo "$output" | grep -iq "error\|warn"; then
    echo "Error or warning detected in Nginx configuration:"
    echo "$output"
    exit 1
  else
    echo "Nginx configuration is OK."
  fi

  # Enable the site
  sudo ln -s /etc/nginx/sites-available/$SITE_NAME /etc/nginx/sites-enabled/

  # reload Nginx
  sudo systemctl reload nginx
fi

if [ $CONFIGURE_MYSQL -eq 1 ]; then

  # *** Creating MySQL database and user
  echo "Creating MySQL database and user"
  read -p "Enter the MySQL root password: " MYSQL_ROOT_PASSWORD
  read -p "Enter the MySQL user password for the new user: " MYSQL_USER_PASSWORD

  MYSQL_USER=$SITE_NAME"_user"
  MYSQL_DATABASE_NAME=$SITE_NAME"_db"

  # change all periods to underscores
  MYSQL_USER=${MYSQL_USER//./_}
  MYSQL_DATABASE_NAME=${MYSQL_DATABASE_NAME//./_}

  # create the database
  mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $MYSQL_DATABASE_NAME;"

  # create the user
  #mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';"

  # grant privileges
  #mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE_NAME.* TO '$MYSQL_USER'@'localhost';"

  # flush privileges
  #mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
fi