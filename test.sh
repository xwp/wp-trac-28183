#!/bin/bash

set -e

cd "$(dirname $0)"
project_dir="$(pwd)"

./reset.sh

if [ ! -e wordpress-3.9.zip ]; then
	wget https://wordpress.org/wordpress-3.9.zip
fi
if [ ! -e wordpress-3.9.1.zip ]; then
	wget https://wordpress.org/wordpress-3.9.1.zip
fi

cd www

cookie_jar=/tmp/trac-28183-cookies.txt
if [ -e $cookie_jar ]; then
	rm /tmp/trac-28183-cookies.txt
fi

twentyfourteen_sidebars_widgets='{"wp_inactive_widgets":[],"sidebar-1":["recent-posts-2","search-2","recent-comments-2","archives-2"],"sidebar-2":["meta-2","categories-2"],"sidebar-3":[],"array_version":3}'
twentythirteen_sidebars_widgets='{"wp_inactive_widgets":[],"sidebar-1":["archives-2","categories-2","meta-2"],"sidebar-2":["recent-posts-2","search-2","recent-comments-2"],"array_version":3}'

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

function access_theme_switch_preview {
	theme="$1"
	curl "http://trac-28183.wordpress.dev/wp-admin/customize.php?theme=$theme" \
		--cookie $cookie_jar \
		--fail \
		--silent \
		-H 'Pragma: no-cache' \
		-H 'Accept-Encoding: gzip,deflate,sdch' \
		-H 'Accept-Language: en-US,en;q=0.8' \
		-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' \
		-H 'Referer: http://trac-28183.wordpress.dev/wp-admin/themes.php' \
		-H 'Connection: keep-alive' \
		-H 'Cache-Control: no-cache' > /dev/null
	return $?
}

function get_theme_mod_sidebars_widgets_status {
	theme=$1
	wp eval "print empty(get_option( 'theme_mods_${theme}' )['sidebars_widgets']) ? 'empty' : 'populated';"
}
function get_option_sidebars_widgets_inactive_status {
	wp eval '$sidebars_widgets = get_option( "sidebars_widgets" ); echo empty( $sidebars_widgets["wp_inactive_widgets"] ) ? "empty" : "populated";'
}

function get_sidebars_widgets_without_orphans {
	wp eval '
		$sidebars_widgets = array();
		foreach ( get_option( "sidebars_widgets" ) as $sidebar_id => $widget_ids ) {
			if ( ! preg_match( "/^orphaned_widgets/", $sidebar_id ) && ! is_null( $widget_ids ) ) {
				$sidebars_widgets[ $sidebar_id ] = $widget_ids;
			}
		}
		echo json_encode( $sidebars_widgets );
	'
}

function reset_themes_sidebars_widgets {
	echo "Resetting themes' widgets"

	echo "Update twentythirteen widgets"
	wp theme activate twentythirteen
	wp option set sidebars_widgets --format=json "$twentythirteen_sidebars_widgets"
	access_widgets_page

	echo "Update twentyfourteen widgets"
	wp theme activate twentyfourteen
	wp option set sidebars_widgets --format=json "$twentyfourteen_sidebars_widgets"
	access_widgets_page
}

#########################################################################################################

echo "Logging in to WordPress"
wp_login

echo "Accessing the widgets page"
access_widgets_page

reset_themes_sidebars_widgets

echo -n 'Make sure that twentyfourteen widgets are restored... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentyfourteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

wp theme activate twentythirteen

if [ "$(get_theme_mod_sidebars_widgets_status twentyfourteen)" == 'populated' ]; then
	echo 'twentyfourteen theme mod for sidebars_widgets populated as expected'
else
	echo 'twentyfourteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi
if [ "$(get_theme_mod_sidebars_widgets_status twentythirteen)" == 'empty' ]; then
	echo 'twentythirteen theme mod for sidebars_widgets empty as expected'
else
	echo 'twentythirteen theme mod for sidebars_widgets POPULATED not as expected'
	exit 1
fi

echo -n 'Make sure that twentythirteen widgets are restored... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentythirteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

wp theme activate twentyfourteen

####################################################################################################

echo -e "\n\nUpgrade to WordPress 3.9:"
wp core upgrade --version=3.9 $project_dir/wordpress-3.9.zip


echo -n 'Confirm that widgets are still intact after upgrade... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentyfourteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

echo "Preview twentythirteen"
preview_theme=twentythirteen
access_theme_switch_preview $preview_theme

echo -n 'Make sure that twentyfourteen widgets are now corrupted due to logic bug... '
if [ "$( get_sidebars_widgets_without_orphans )" != "$twentyfourteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

echo -n 'Confirm that the previewed theme widgets are now applied to the active theme due to logic bug... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentythirteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

if [ "$(get_theme_mod_sidebars_widgets_status twentyfourteen)" == 'empty' ]; then
	echo 'twentyfourteen theme mod for sidebars_widgets empty as expected, due to logic error'
else
	echo 'twentyfourteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi
if [ "$(get_theme_mod_sidebars_widgets_status twentythirteen)" == 'empty' ]; then
	echo 'twentythirteen theme mod for sidebars_widgets empty as expected'
else
	echo 'twentythirteen theme mod for sidebars_widgets POPULATED not as expected'
	exit 1
fi


################################################################################################

reset_themes_sidebars_widgets

sidebars_widgets_before_upgrade=$(wp option get sidebars_widgets)

echo -e "\n\nUpgrade to WordPress 3.9.1:"
wp core upgrade --version=3.9.1 $project_dir/wordpress-3.9.1.zip

sidebars_widgets_after_upgrade=$(wp option get sidebars_widgets)

if [ "$sidebars_widgets_before_upgrade" == "$sidebars_widgets_after_upgrade" ]; then
	echo "Sidebars widgets remained intact after upgrade to 3.9.1"
else
	echo "Sidebars widgets changed after upgrade to 3.9.1"
	exit 1
fi

if [ "$(get_theme_mod_sidebars_widgets_status twentyfourteen)" == 'populated' ]; then
	echo 'twentyfourteen theme mod for sidebars_widgets still populated as expected, due to logic error in 3.9'
else
	echo 'twentyfourteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi
if [ "$(get_theme_mod_sidebars_widgets_status twentythirteen)" == 'populated' ]; then
	echo 'twentythirteen theme mod for sidebars_widgets still populated as expected, due to logic error in 3.9'
else
	echo 'twentythirteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi

reset_themes_sidebars_widgets


wp theme activate twentyfourteen
if [ "$(get_theme_mod_sidebars_widgets_status twentyfourteen)" == 'empty' ]; then
	echo 'twentyfourteen theme mod for sidebars_widgets now empty as expected'
else
	echo 'twentyfourteen theme mod for sidebars_widgets POPULATED not as expected'
	exit 1
fi
if [ "$(get_theme_mod_sidebars_widgets_status twentythirteen)" == 'populated' ]; then
	echo 'twentythirteen theme mod for sidebars_widgets now populated as expected'
else
	echo 'twentythirteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi

wp theme activate twentythirteen
if [ "$(get_theme_mod_sidebars_widgets_status twentythirteen)" == 'empty' ]; then
	echo 'twentythirteen theme mod for sidebars_widgets now empty as expected'
else
	echo 'twentythirteen theme mod for sidebars_widgets POPULATED not as expected'
	exit 1
fi
if [ "$(get_theme_mod_sidebars_widgets_status twentyfourteen)" == 'populated' ]; then
	echo 'twentyfourteen theme mod for sidebars_widgets now populated as expected'
else
	echo 'twentyfourteen theme mod for sidebars_widgets EMPTY not as expected'
	exit 1
fi

wp theme activate twentyfourteen

sidebars_widgets_before_theme_switch_preview=$(wp option get sidebars_widgets)
echo "Preview twentythirteen"
preview_theme=twentythirteen
access_theme_switch_preview $preview_theme
sidebars_widgets_after_theme_switch_preview=$(wp option get sidebars_widgets)

echo -n 'Make sure that twentyfourteen widgets now do not get corrupted... '
if [ "$sidebars_widgets_before_theme_switch_preview" == "$sidebars_widgets_after_theme_switch_preview" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

access_widgets_page

echo -n 'Confirm that the twentyfourteen widgets still applied... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentyfourteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi


wp theme activate twentythirteen

sidebars_widgets_before_theme_switch_preview=$(wp option get sidebars_widgets)
echo "Preview twentyfourteen"
preview_theme=twentyfourteen
access_theme_switch_preview $preview_theme
sidebars_widgets_after_theme_switch_preview=$(wp option get sidebars_widgets)

echo -n 'Make sure that twentythirteen widgets now do not get corrupted... '
if [ "$sidebars_widgets_before_theme_switch_preview" == "$sidebars_widgets_after_theme_switch_preview" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

access_widgets_page

echo -n 'Confirm that the twentythirteen widgets still applied... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentythirteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi

wp theme activate twentyfourteen

echo -n 'Confirm that the twentyfourteen widgets still applied... '
if [ "$( get_sidebars_widgets_without_orphans )" == "$twentyfourteen_sidebars_widgets" ]; then
	echo 'pass'
else
	echo 'fail'
	exit 1
fi


################################################################

echo -e "\n\nMake sure that twentyfourteen theme upgrade keeps widgets intact"

sidebars_widgets_before=$(wp option get sidebars_widgets)
wp theme update twentyfourteen
sidebars_widgets_after=$(wp option get sidebars_widgets)

if [ "$sidebars_widgets_before" == "$sidebars_widgets_after" ]; then
	echo "Widgets intact after theme upgrade"
else
	echo "Widgets corrupted after theme upgrade"
	exit 1
fi

echo -e "\nTests pass"
