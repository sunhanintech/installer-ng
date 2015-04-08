FROM krallin/ubuntu-tini:14.04

ENV SCALR_VERSION 5.5.0.ee~nightly.20150408154257.293.3fea55d.936f3b2~ubuntu.trusty-1
ADD ./scalr-server_${SCALR_VERSION}_amd64.deb /
RUN dpkg -i /scalr-server_${SCALR_VERSION}_amd64.deb

ADD docker-entrypoint.sh /

ENTRYPOINT ["/usr/local/bin/tini", "--", "/docker-entrypoint.sh"]
CMD ["scalr-server"]

EXPOSE 80 8080
