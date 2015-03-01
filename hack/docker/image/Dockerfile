FROM ubuntu:14.04

ENV SCALR_VERSION 5.3.2.ee~nightly.20150227043604.209.dc76268.61ddb45~ubuntu.trusty-1
ADD ./scalr-server_${SCALR_VERSION}_amd64.deb /
RUN dpkg -i /scalr-server_${SCALR_VERSION}_amd64.deb

ENV TINI_VERSION v0.3.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ADD docker-entrypoint.sh /

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["scalr-server"]

EXPOSE 80 8080
