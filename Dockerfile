FROM centos/devtoolset-7-toolchain-centos7

USER root

# Some packages we need
RUN yum -y install git && \
    yum -y install patch && \
    yum -y install make && \
    yum -y install epel-release \
    yum -y update && \
    yum -y install cmake3 && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    yum -y install python36-devel && \
    yum -y install python36-pip && \
    pip3 install setuptools --upgrade && \
    pip3 install wheel

# Environment
ENV TMPDIR /tmp

# Get sources
RUN cd $TMPDIR && \
    git clone https://bitbucket.org/wlav/cppyy-backend.git && \
    git clone https://bitbucket.org/wlav/CPyCppyy.git && \
    git clone https://bitbucket.org/wlav/cppyy.git

# Install cppyy-cling
ADD create_src_directory.py $TMPDIR/cppyy-backend/cling
RUN cd $TMPDIR/cppyy-backend/cling && \
    python3 setup.py egg_info && \
    python3 create_src_directory.py && \
    pip3 install .

# Install cppyy-backend - force installation in lib (not lib64)
RUN cd $TMPDIR/cppyy-backend/clingwrapper && \
    pip3 install . --install-option="--install-lib=/usr/local/lib/python3.6/site-packages"

# Install CPyCppyy - force installation in lib (not lib64)
RUN cd $TMPDIR/CPyCppyy && \
    pip3 install . --install-option="--install-lib=/usr/local/lib/python3.6/site-packages"

# Copy CPyCppyy headers to include directory for cppyy to find them
ENV INCLUDE_DIR /usr/local/include
RUN cp -r ${INCLUDE_DIR}/python3.6m/CPyCppyy $INCLUDE_DIR

# Install cppyy
RUN cd $TMPDIR/cppyy && \
    pip3 install .

# Add test user and switch to it
RUN adduser cppyy-test
USER cppyy-test

# Go to home dir
ENV HOME /home/cppyy-test
WORKDIR $HOME

# Add test file and script
ADD rr_test.py rr_test.py

# Run test
CMD [ "python3", "rr_test.py" ]

