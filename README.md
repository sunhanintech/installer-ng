Scalr Next Generation Installer
===============================

An installer for [Scalr Open Source][0], with support for:

  + Ubuntu: 12.04, 14.04
  + RHEL: 6, 7
  + CentOS: 6, 7

If you run into any issues, or have suggestions, get in touch with us at
onboarding@scalr.com, or [file an issue][1].


Usage
=====

### Choosing a Server ###

We strongly suggest that you use a fresh install of your OS of choice to
install Scalr. A cloud instance is a great choice.

### Download ###

Log in to the server you'd like to install Scalr on, and run the following
command, preferably as root.

    curl -sfSLO https://raw.githubusercontent.com/Scalr/installer-ng/master/dist/install.sh

You might want to double-check that the `install.sh` file that was downloaded
does match the installer script as it is presented here.

### Install Scalr ###

Run the following, as root.

    bash install.sh

If you'd like to anything more complex, like install a specific Scalr version,
then review the [instructions on the Scalr Wiki][10].

Note: we recommend that you run this command using GNU screen, so that the
installation process isn't interrupted if your SSH connection drops.


### Use Scalr ###

Visit your server on port 80 to get started. The output of the install script
contains your login credentials.

All generated credentials are logged to `/root/solo.json`, so you can
also retrieve them there.


Upgrading
=========

You may use the Scalr Installer to upgrade your Scalr install. However, be
mindful that that the Installer uses semantic versioning, and that there are
no guarantees that a new major version will not prevent upgrading a Scalr
install performed with an earlier major version.


Supported OSes
==============

  + Ubuntu 12.04
  + RHEL 6
  + CentOS 6


License
=======

Apache 2.0


  [0]: https://github.com/Scalr/scalr
  [1]: https://github.com/Scalr/installer-ng/issues
  [10]: https://scalr-wiki.atlassian.net/wiki/x/AoD4
