FROM __PLATFORM_NAME__:__PLATFORM_VERSION__

# Head declarations
MAINTAINER Thomas Orozco <thomas@scalr.com>

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD ./build/__PLATFORM_FAMILY__/bootstrap.sh /
RUN /bootstrap.sh

ADD ./build/shared/install_rvm.sh /
RUN /install_rvm.sh

ADD ./build/__PLATFORM_FAMILY__/install_utils.sh /
RUN /install_utils.sh

RUN bash --login -c "gem install package_cloud bundler berkshelf"

ADD ./Gemfile /Gemfile
ENV BUNDLE_GEMFILE /Gemfile
RUN bash --login -c "bundle install"

ADD ./build/__PLATFORM_FAMILY__/prepare_test.sh /
ADD ./build/__PLATFORM_FAMILY__/teardown_test.sh /

ADD ./build/shared /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/build.sh"]
