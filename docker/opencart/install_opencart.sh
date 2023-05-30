#!/bin/bash

source /var/www/opencart/.env

# Access the variables
echo "DB_PORT: $DB_PORT"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_DATABASE"
echo "DB_PASSWORD: $DB_DATABASE"

echo "OPENCART_USERNAME: $OPENCART_USERNAME"
echo "OPENCART_PASSWORD: $OPENCART_PASSWORD"
echo "OPENCART_EMAIL: $OPENCART_EMAIL"


# Create 'releases' directory if it doesn't exist
mkdir -p releases

# Set write permissions for 'releases' directory
chmod -R 777 releases

# Function to download and install OpenCart release
download_releases() {
  local RELEASE_NAME="$1"
  local DOWNLOAD_LINK="$2"
  local UNZIP_FOLDER="$3"

  mkdir -p "/var/www/opencart/releases/$RELEASE_NAME"

  ZIP_FILE="/var/www/opencart/releases/${RELEASE_NAME}_opencart.zip"
  if [ ! -f "$ZIP_FILE" ]; then
    wget -O "$ZIP_FILE" "$DOWNLOAD_LINK" || true
  fi

  unzip -o "$ZIP_FILE" -d "/var/www/opencart/releases/$RELEASE_NAME" || true
  cp -rf "/var/www/opencart/releases/$RELEASE_NAME/$UNZIP_FOLDER/"* "/var/www/opencart/releases/$RELEASE_NAME" || true

  # Rename config files
  mv -f "/var/www/opencart/releases/$RELEASE_NAME/config-dist.php" "/var/www/opencart/releases/$RELEASE_NAME/config.php" || true
  mv -f "/var/www/opencart/releases/$RELEASE_NAME/admin/config-dist.php" "/var/www/opencart/releases/$RELEASE_NAME/admin/config.php" || true

  rm -rf "/var/www/opencart/releases/$RELEASE_NAME/$UNZIP_FOLDER"
}

copy_releases() {
  local SOURCE_FOLDER="/var/www/opencart/releases/$1"
  local DESTINATION_FOLDER="/var/www/opencart/$2"
  mkdir -p "$DESTINATION_FOLDER"
  echo "Copying files from $SOURCE_FOLDER to $DESTINATION_FOLDER"
  cp -rf "$SOURCE_FOLDER/"* "$DESTINATION_FOLDER" || true
}

# Download and install OpenCart releases
download_releases "1.5.6.4" "https://github.com/opencart/opencart/archive/refs/tags/1.5.6.4.zip" "opencart-1.5.6.4/upload"
download_releases "2.1.0.2" "https://github.com/opencart/opencart/archive/refs/tags/2.1.0.2.zip" "opencart-2.1.0.2/upload"
download_releases "2.3.0.2" "https://github.com/opencart/opencart/releases/download/2.3.0.2/2.3.0.2-compiled.zip" "upload"
download_releases "3.0.3.8" "https://github.com/opencart/opencart/releases/download/3.0.3.8/opencart-3.0.3.8.zip" "upload"
download_releases "4.0.2.1" "https://github.com/opencart/opencart/releases/download/4.0.2.1/opencart-4.0.2.1.zip" "opencart-4.0.2.1/upload"

## Copy releases to developing
copy_releases "1.5.6.4" "dev15"
copy_releases "2.1.0.2" "dev21"
copy_releases "2.3.0.2" "dev23"
copy_releases "3.0.3.8" "dev30"
copy_releases "4.0.2.1" "dev40"

## Copy releases to demonstration
copy_releases "1.5.6.4" "demo15"
copy_releases "2.1.0.2" "demo21"
copy_releases "2.3.0.2" "demo23"
copy_releases "3.0.3.8" "demo30"
copy_releases "4.0.2.1" "demo40"

echo "Deleting releases files"
rm -rf "/var/www/opencart/releases"

echo "SET CHOWN www-data"
chown -R www-data:www-data /var/www/opencart
chmod -R 755 /var/www/opencart

#####################################################
# INSTALLING DATABASE
#####################################################

echo "START INSTALLING DATABASE && CONFIG"


install_database() {

  local CLI_PATH="/var/www/opencart/$1/install/cli_install.php"
  local HTTP_SERVER="http://localhost/$1/"

  echo "BEGIN INSTALLATION FOR http_server: $HTTP_SERVER"

  php "$CLI_PATH" install \
    --username    "$OPENCART_USERNAME" \
     --email       "$OPENCART_EMAIL" \
     --password    "$OPENCART_PASSWORD" \
     --http_server "http://localhost/" \
     --db_driver   mysqli \
     --db_hostname db \
     --db_host db \
     --db_username "$DB_USERNAME" \
     --db_user     "$DB_USERNAME" \
     --db_password "$DB_PASSWORD" \
     --db_database "$DB_DATABASE" \
     --db_port     "$DB_PORT" \
     --db_prefix   "$1"_ \
     --agree_tnc   "yes" \
     --http_server "$HTTP_SERVER"

  rm -rf "/var/www/opencart/$1/install"
}


install_database demo40
install_database dev40

# Find the available PHP versions
versions=$(update-alternatives --list php)

# shellcheck disable=SC2068
for path in ${versions[@]}; do
    if [[ $path == *"/php7.3"* ]]; then
        update-alternatives --set php "$path"
        break
    fi
done

install_database demo30
install_database dev30

install_database demo23
install_database dev23

install_database demo21
install_database dev21

# Loop through the versions and select the desired PHP version
# shellcheck disable=SC2068
for path in ${versions[@]}; do
    if [[ $path == *"/php5.6"* ]]; then
        update-alternatives --set php "$path"
        break
    fi
done

#php -v

install_database dev15
install_database demo15

echo "INSTALLATION SUCCESSFULLY ENDED"