# Install system dependencies.
RUN yum install -y curl which tar sudo && \
    yum install -y rpm-build && \
    yum install -y python python-pip python-setuptools
