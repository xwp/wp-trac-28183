#!/bin/bash

cd "$(dirname $0)"

source db-creds.sh

if [ -e www ]; then
	wp --allow-root --path=www/ db reset --yes
	rm -r www
fi

mkdir www
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
