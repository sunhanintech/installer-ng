Test Image
==========

Build Library
-------------

Download the Scalr User Client Library and built it:

    cd /tmp
    git clone git@github.com:Scalr/scalr-user-client.git
    cd scalr-user-client
    python setup.py sdist

Move the resulting archive (found here `sdist`) in *this* directory.

Update the `CLIENT_VERSION` variable if needed.

NOTE: the Scalr User Client is private, so you need to be authenticated.


Build Image
-----------

    docker build -t scalr-server-test .
