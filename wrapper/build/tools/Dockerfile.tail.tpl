# Install RVM / recent Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    rm -rf /var/lib/apt/lists/*

# Install packaging dependencies
RUN bash --login -c "gem install fpm package_cloud"

# Launch
ENV TOOLS_DIR /build/tools
ENV DIST_DIR /build/dist

CMD ["bash", "--login", "${TOOLS_DIR}/wrap.sh"]

# We actually add the scalr-manage pkg dir into the image, because accessing it from a
# volume is too slow when using boot2docker (which is the very purpose of this image)
ADD ./tools ${TOOLS_DIR}
ADD ./pkg.tar.gz /build
