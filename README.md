NOTE: This installer is still in beta, so if you are using an OS that the
[legacy installer](https://github.com/Scalr/installer) supports (Ubuntu), you
may want to use that instead.

Scalr Next Generation Installer
===============================

An experimental installer for [Scalr Open Source][0].

This installer supports Ubuntu 12.04, Red Hat Enterprise Linux 6, and CentOS 6.


Usage
=====

### Download ###

Log in to the server you'd like to install Scalr on, and run the following
command, preferably as root.

    curl -O https://raw.github.com/Scalr/installer-ng/master/scripts/install.py

### Install ###

Run the following, as root.

    python install.py

Note: we recommend that you run this command using GNU screen, so that the
installation process isn't interrupted if your SSH connection drops.


### Use ###

Visit your server on port 80 to get started. The output of the install script
will contain your login credentials.


Supported OSes
==============

  + Ubuntu 12.04
  + RHEL 6
  + CentOS 6


License
=======

Apache 2.0


  [0]: https://github.com/Scalr/scalr
