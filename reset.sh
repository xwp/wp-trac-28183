#!/bin/bash

cd "$(dirname $0)"

source db-creds.sh

echo "Reset database"
mysql -u root -proot -e "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET $DB_CHARSET"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"

if [ -e www ]; then
	rm -r www
fi

# Note: Using /tmp on Vagrant for a great speed up since no synced folders
if [ -e /tmp/trac-28183-www ]; then
	rm -r /tmp/trac-28183-www
fi
mkdir /tmp/trac-28183-www
ln -s /tmp/trac-28183-www www
cd www
wp --allow-root core download --version=3.8.3


wp  --allow-root core config \
	--dbname=$DB_NAME \
	--dbuser=$DB_USER \
	--dbpass=$DB_PASSWORD \
	--dbcharset=$DB_CHARSET

wp  --allow-root core install \
	--url=http://trac-28183.wordpress.dev \
	--title="Trac #28183 test site" \
	--admin_user=admin \
	--admin_password=password \
	--admin_email=admin@example.com

#--extra-php="define( 'WP_CONTENT_DIR', __DIR__ . '/content' ); define( 'WP_CONTENT_URL', 'http://$SITE_HOST/content' );"
