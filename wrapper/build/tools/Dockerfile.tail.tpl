# Install RVM / recent Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    rm -rf /var/lib/apt/lists/*

# Install packaging dependencies
RUN bash --login -c "gem install fpm package_cloud"

# Launch
ENV TOOLS_DIR /build/tools
ENV DIST_DIR /build/dist

# Set locale to something UTF-8 to please package_cloud
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# NOTE - Hopefully one day we can use the ENV here, but currently
# to use ENTRYPOINT + CMD, we need the JSON form.
# We need shell interpolation here
ENTRYPOINT ["/build/tools/wrap.sh"]
CMD ["bash", "--login", "/build/tools/build.sh"]

# We actually add the scalr-manage pkg dir into the image, because accessing it from a
# volume is too slow when using boot2docker (which is the very purpose of this image)
ADD ./tools ${TOOLS_DIR}
ADD ./pkg.tar.gz /build
