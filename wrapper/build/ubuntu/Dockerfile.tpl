# UTF-8 isn't enabled by default on this image. Set it up.
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install system dependencies.
# Note that python-setuptools will pull in Python if it's not already installed
RUN apt-get update && \
    apt-get install -y curl sudo && \
    apt-get install -y python-pip python-setuptools && \
    rm -rf /var/lib/apt/lists/*
