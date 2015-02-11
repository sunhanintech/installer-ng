FROM ubuntu:14.04

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y curl \
 && curl -O https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.deb \
 && bash script.deb \
 && rm -rf /var/lib/apt/lists/*

ENV SCALR_VERSION 5.1.0.oss~nightly.20150211043641.177.7f0df7f.7791ef1~ubuntu.trusty-1

RUN apt-get update \
 && apt-get install -y "scalr-server=${SCALR_VERSION}"\
 && rm -rf /var/lib/apt/lists/*

ADD docker-entrypoint.sh /

EXPOSE 80 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["scalr-server"]
