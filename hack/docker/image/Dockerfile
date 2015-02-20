FROM ubuntu:14.04

ENV SCALR_VERSION 5.3.2.ee~nightly.20150220180032.199.62c28fe.de1a220~ubuntu.trusty-1

ADD ./scalr-server_${SCALR_VERSION}_amd64.deb /

RUN dpkg -i /scalr-server_${SCALR_VERSION}_amd64.deb

ADD docker-entrypoint.sh /

EXPOSE 80 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["scalr-server"]
