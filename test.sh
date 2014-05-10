#!/bin/bash

cd "$(dirname $0)"

#./reset.sh

cd www

cookie_jar=/tmp/trac-28183-cookies.txt
if [ -e $cookie_jar ]; then
	rm /tmp/trac-28183-cookies.txt
fi

function wp_login {

	# Set the initial cookies
	curl 'http://trac-28183.wordpress.dev/wp-login.php' \
		-i \
		--cookie-jar $cookie_jar \
		--silent \
		-H 'Pragma: no-cache' \
		-H 'Origin: http://trac-28183.wordpress.dev' \
		-H 'Accept-Encoding: gzip,deflate,sdch' \
		-H 'Accept-Language: en-US,en;q=0.8' \
		-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' \
		-H 'Content-Type: application/x-www-form-urlencoded' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
		-H 'Cache-Control: no-cache' \
		-H 'Referer: http://trac-28183.wordpress.dev/wp-login.php?redirect_to=http%3A%2F%2Ftrac-28183.wordpress.dev%2Fwp-admin%2F&reauth=1' \
		-H 'Connection: keep-alive' \
		 > /dev/null

	# Try to login
	curl 'http://trac-28183.wordpress.dev/wp-login.php' \
		--fail \
		--location \
		--silent \
		--cookie-jar $cookie_jar \
		--cookie $cookie_jar \
		-H 'Pragma: no-cache' \
		-H 'Origin: http://trac-28183.wordpress.dev' \
		-H 'Accept-Encoding: gzip,deflate,sdch' \
		-H 'Accept-Language: en-US,en;q=0.8' \
		-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' \
		-H 'Content-Type: application/x-www-form-urlencoded' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
		-H 'Cache-Control: no-cache' \
		-H 'Referer: http://trac-28183.wordpress.dev/wp-login.php?redirect_to=http%3A%2F%2Ftrac-28183.wordpress.dev%2Fwp-admin%2F&reauth=1' \
		-H 'Connection: keep-alive' \
		--data 'log=admin&pwd=password&wp-submit=Log+In&redirect_to=http%3A%2F%2Ftrac-28183.wordpress.dev%2Fwp-admin%2F&testcookie=1' \
		 > /dev/null
	return $?
}

function access_widgets_page {
	curl 'http://trac-28183.wordpress.dev/wp-admin/widgets.php' \
		--cookie $cookie_jar \
		--fail \
		--silent \
		-H 'Pragma: no-cache' \
		-H 'Accept-Encoding: gzip,deflate,sdch' \
		-H 'Accept-Language: en-US,en;q=0.8' \
		-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
		-H 'Referer: http://trac-28183.wordpress.dev/wp-admin/index.php' \
		-H 'Connection: keep-alive' \
		-H 'Cache-Control: no-cache' > /dev/null
	return $?
}

function get_theme_mod_sidebars_widgets {
	theme=$1
	wp eval "print empty(get_option( 'theme_mods_${theme}' )['sidebars_widgets']) ? 'empty' : 'populated';"
}

echo -n "Logging in to WordPress..."
if wp_login; then
	echo 'done'
else
	echo 'fail'
	exit 1
fi

echo -n "Accessing the widgets page..."
if access_widgets_page; then
	echo 'done'
else
	echo 'fail'
	exit 1
fi

wp theme install --activate --version=1.5 twentyten # 1.6 is the latest
wp theme install --activate --version=1.7 twentyeleven # 1.8 is the latest
wp theme activate twentytwelve
wp theme activate twentythirteen
wp theme activate twentyfourteen

for theme in twenty{ten,eleven,twelve,thirteen}; do
	if [ $(get_theme_mod_sidebars_widgets $theme) == 'populated' ]; then
		echo "$theme: sidebars_widgets theme mod populated"
	else
		echo "$theme: sidebars_widgets theme mod empty"
		exit 1
	fi
done

theme=twentyfourteen
if [ $(get_theme_mod_sidebars_widgets $theme) == 'empty' ]; then
	echo "$theme: sidebars_widgets theme mod empty as expected"
else
	echo "$theme: sidebars_widgets theme mod populated :-("
	exit 1
fi




#wp option get theme_mods_twentyten
#wp option get theme_mods_twentyeleven
#wp option get theme_mods_twentythirteen
#wp option get theme_mods_twentyfourteen


exit

access_widgets_page
#wp option get sidebars_widgets
#wp theme mod get sidebars_widgets

access_widgets_page
#wp option get sidebars_widgets
#wp theme mod get sidebars_widgets


exit
access_widgets_page
wp option get sidebars_widgets
wp theme mod get sidebars_widgets
wp theme activate twentyfourteen
access_widgets_page
wp theme mod get sidebars_widgets

wp option get theme_mods_twentythirteen
wp option get theme_mods_twentyfourteen

# wp core upgrade --version=3.9.1
