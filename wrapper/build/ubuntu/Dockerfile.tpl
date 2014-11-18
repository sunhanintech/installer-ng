# UTF-8 isn't enabled by default on this image. Set it up.
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Install system dependencies.
# Note that python-setuptools will pull in Python if it's not already installed
RUN apt-get update && \
    apt-get install -y curl sudo && \
    apt-get install -y python-pip python-setuptools && \
    rm -rf /var/lib/apt/lists/*
