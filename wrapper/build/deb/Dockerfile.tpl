MAINTAINER Thomas Orozco <thomas@scalr.com>

# System Dependencies
RUN apt-get update && \
    apt-get install -y devscripts debhelper gnupg-agent python-bzrlib && \
    apt-get install -y python-pip python-all && \
    apt-get install -y ruby ruby-dev ruby-bundler && \
    rm -rf /var/lib/apt/lists/*

# Packaging Dependencies (we want a really up to date version)
RUN gem install fpm package_cloud

ENV TOOLS_DIR /build/tools
ENV DIST_DIR /build/dist

CMD "${TOOLS_DIR}/deb_wrap.sh"

# We actually add the scalr-manage pkg dir into the image, because accessing it from a
# volume is too slow when using boot2docker (which is the very purpose of this image)
ADD ./tools ${TOOLS_DIR}
ADD ./pkg.tar.gz /build
