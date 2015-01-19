RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    rm -rf /var/lib/apt/lists/* || true && \
    yum clean all || true

RUN bash --login -c "gem install package_cloud bundler berkshelf"

ADD ./entrypoint.sh /
ADD ./git_ssh_wrapper.sh /
ADD ./build.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/build.sh"]
