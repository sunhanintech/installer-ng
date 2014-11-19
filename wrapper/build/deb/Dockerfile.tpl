MAINTAINER Thomas Orozco <thomas@scalr.com>

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

# Install RVM / recent Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    rm -rf /var/lib/apt/lists/*

# Install packaging dependencies
RUN bash --login -c "gem install fpm package_cloud"

# Launch
ENV TOOLS_DIR /build/tools
ENV DIST_DIR /build/dist

# NOTE: We use a login shell here to parse the rvm profile
CMD ["bash", "--login", "${TOOLS_DIR}/deb_wrap.sh"]

# We actually add the scalr-manage pkg dir into the image, because accessing it from a
# volume is too slow when using boot2docker (which is the very purpose of this image)
ADD ./tools ${TOOLS_DIR}
ADD ./pkg.tar.gz /build
