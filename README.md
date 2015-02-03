Scalr Installer
===============

Welcome to the Scalr installer!

Install instructions can be found below in this README, or
[on the Scalr Wiki][00].


Supported Platforms
-------------------

The Scalr Installer supports the following platforms:

  + Ubuntu: 12.04 and 14.04.
  + CentOS / RHEL: 6 and 7.

Support for similar distributions (e.g. Debian) can be added. Feel free to
file an issue to request support.


Deploying Scalr
===============

Step 1: Installation
--------------------

Start by deploying the Scalr package appropriate for your system.

### Ubuntu ###

    curl https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.deb | sudo bash
    apt-get install -y scalr-server

### CentOS / RHEL ###

    curl https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.rpm | sudo bash
    yum install -y scalr-server


Step 2: Configuration
---------------------

Once you've deployed the packages, you need to configure Scalr. Since Scalr
can auto-detect configuration in most common deployment scenarios (e.g. when
deploying on a cloud), you should first check whether the auto-detected
configuration is suitable.

Run the following command, and follow the instructions (`/usr/bin` needs to
be on your `PATH`):

    scalr-server-wizard

If you're happy with the configuration, run:

    scalr-server-ctl reconfigure

If not, visit this link: [Packages - Installed Usage][20].


Step 3: Access Scalr
--------------------

Once the `reconfigure` step, your Scalr instance is ready to use.

Get your admin password from the Scalr secrets file in
`/etc/scalr-server/scalr-server-secrets.json`, under `admin_password`.

The admin username is `admin`.

Use those credentials to login. Scalr is listening on port 80 on your server.


Next Steps
==========

We encourage you to review the following documentation entries:

  + [First Steps as a Scalr Administrator][10] - Unless you've administered a
    Scalr install before, this is where you should start.
  + [Packages - Advanced Usage][20] - If you'd like to deploy a more
    complicated setup than the default configuration.


  [00]: https://scalr-wiki.atlassian.net/wiki/x/QgAeAQ
  [10]: https://scalr-wiki.atlassian.net/wiki/x/fQAeAQ
  [20]: https://scalr-wiki.atlassian.net/wiki/x/RgAeAQ
