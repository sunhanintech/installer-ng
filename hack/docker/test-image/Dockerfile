FROM krallin/ubuntu-tini

ENV CLIENT_VERSION 0.7.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends python python-pip && \
    rm -rf /var/lib/apt/lists/*

ADD ./scalr-user-client-${CLIENT_VERSION}.tar.gz /

RUN cd "/scalr-user-client-${CLIENT_VERSION}" && \
    python setup.py install --single-version-externally-managed --root=/

ADD ./test-script.py /

ENTRYPOINT ["python", "/test-script.py"]
CMD ["create", "login", "ec2"]
