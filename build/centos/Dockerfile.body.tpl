RUN yum install -y epel-release \
    && yum clean all

RUN yum install -y which curl tar gpg python \
    && yum clean all

RUN yum install -y curl rpm-build fakeroot cmake automake libtool rsync \
                   git swig xz imake perl-ExtUtils-MakeMaker \
    && yum clean all

