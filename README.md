# Test cases for WordPress Trac [#28183](https://core.trac.wordpress.org/ticket/28183)
**“Widget contents removed from widget areas upon upgrade to 3.9.1”**

This repo contains tests which install WordPress 3.8.3, and verifies the
problem in 3.9: [#27897](https://core.trac.wordpress.org/ticket/27897) “Theme
preview empties sidebar on active theme”. Then it upgrades to 3.9.1 and tests
that the fix works as expected, and that the sidebars no longer get corrupted
when previewing theme switches.

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
