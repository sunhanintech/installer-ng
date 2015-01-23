FROM __PLATFORM_NAME__:__PLATFORM_VERSION__

# Head declarations
MAINTAINER Thomas Orozco <thomas@scalr.com>

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD ./build/__PLATFORM_NAME__/bootstrap.sh /

RUN /bootstrap.sh

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    rm -rf /var/lib/apt/lists/* || true && \
    yum clean all || true

ADD ./build/__PLATFORM_NAME__/install_utils.sh /
RUN /install_utils.sh

RUN bash --login -c "gem install package_cloud bundler berkshelf"

ADD ./Gemfile /builder/Gemfile
RUN bash --login -c "cd /builder && bundle install --binstubs"

ADD ./build/__PLATFORM_NAME__/prepare_test.sh /

ADD . /builder
ENTRYPOINT ["/builder/build/shared/entrypoint.sh"]
CMD ["/builder/build/shared/build.sh"]
