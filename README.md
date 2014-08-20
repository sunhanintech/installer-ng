Scalr Next Generation Installer
===============================

An installer for [Scalr Open Source][0].

This installer supports Ubuntu 12.04, Red Hat Enterprise Linux 6, and CentOS 6.

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

    curl -L -O https://raw.github.com/Scalr/installer-ng/master/scripts/install.py

You might want to double-check that the `install.py` file that was downloaded
does match the installer script as it is presented here.

Note: if the downloaded file is not a Python script, and instead is an HTML
page reporting a "Bad Request", then add the `--sslv3` flag to the
aforementioned `curl` command line, and download again.

### Install Scalr ###

Run the following, as root.

    python install.py

If you'd like to install a specific Scalr version (e.g. a release candidate),
use `python install.py --advanced`, and follow the instructions provided
on-screen.

Note: we recommend that you run this command using GNU screen, so that the
installation process isn't interrupted if your SSH connection drops.


### Use Scalr ###

Visit your server on port 80 to get started. The output of the install script
contains your login credentials.

All generated credentials are logged to `/root/solo.json`, so you can
also retrieve them there.

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
