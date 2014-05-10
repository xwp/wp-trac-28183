#!/bin/bash

cd "$(dirname $0)"

printf "Setting up: %s\n" $(basename $(pwd))

source db-creds.sh

# Make a database, if we don't already have one
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET $DB_CHARSET"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"

mkdir -p www

./reset.sh
