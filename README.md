# Test cases for WordPress Trac [#28183](https://core.trac.wordpress.org/ticket/28183)
**“Widget contents removed from widget areas upon upgrade to 3.9.1”**

This repo contains tests which install WordPress 3.8.3, then upgrades to 3.9 and
verifies the bug in 3.9: [#27897](https://core.trac.wordpress.org/ticket/27897)
“Theme preview empties sidebar on active theme”. Then the test upgrades to 3.9.1
and verifies that the fix works as expected, and that the sidebars no longer
get corrupted when previewing theme switches. The tests use WP-CLI to do
upgrades and theme switches, while `curl` is used to simulate users logging in
to WordPress and accessing the widgets admin page and theme-switch customizer.
The database (`wordpress_trac28183`) and WordPress install get reset with each
run of the tests; the WordPress install gets placed in `/tmp` to speed up
the execution time by avoiding the overhead of the synced folder.

This repo is designed to be cloned into [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV),
and upon provisioning, it will automatically create a local test site at `http://trac-28183.wordpress.dev`.

To then run the tests, you can just run [`./test.sh`](test.sh).

To summarize:

```sh
cd vvv/www
git clone git@github.com:x-team/wp-trac-28183.git trac-28183.wordpress.dev
vagrant up --provision
vagrant ssh -c 'cd /srv/www/trac-28183.wordpress.dev && ./test.sh'
```

The [tests](test.sh) as written **all pass**. See [current output](output.txt).
