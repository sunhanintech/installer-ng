RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN apt-get update && apt-get install -y curl tar python \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y curl build-essential pkg-config cmake automake libtool rsync git swig xutils-dev groff-base \
    && rm -rf /var/lib/apt/lists/*

