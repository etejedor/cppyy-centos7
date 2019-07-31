FROM centos/devtoolset-7-toolchain-centos7

USER root

# Some packages we need
RUN yum -y install git && \
    yum -y install patch && \
    yum -y install python-devel && \
    yum -y install make && \
    yum -y install epel-release \
    yum -y update && \
    yum -y install cmake3 && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake && \
    yum -y install python-pip && \
    pip install setuptools --upgrade

# Environment
ENV TMPDIR /tmp

# Get sources
RUN cd $TMPDIR && \
    git clone https://bitbucket.org/wlav/cppyy-backend.git && \
    git clone https://bitbucket.org/wlav/CPyCppyy.git && \
    git clone https://bitbucket.org/wlav/cppyy.git

# Install cppyy-cling
RUN cd $TMPDIR/cppyy-backend/cling && \
    python setup.py egg_info && \
    python create_src_directory.py && \
    pip install .

# Install cppyy-backend - force installation in lib (not lib64)
RUN cd $TMPDIR/cppyy-backend/clingwrapper && \
    pip install . --install-option="--install-lib=/usr/lib/python2.7/site-packages"

# Install CPyCppyy - force installation in lib (not lib64)
RUN cd $TMPDIR/CPyCppyy && \
    pip install . --install-option="--install-lib=/usr/lib/python2.7/site-packages"

# Copy CPyCppyy headers to include directory for cppyy to find them
ENV INCLUDE_DIR /usr/include
RUN cp -r ${INCLUDE_DIR}/python2.7/CPyCppyy $INCLUDE_DIR

# Install cppyy
RUN cd $TMPDIR/cppyy && \
    pip install .

# Install pyenv dependencies
RUN yum -y install zlib-devel && \
    yum -y install bzip2-devel && \
    yum -y install readline-devel && \
    yum -y install sqlite-devel && \
    yum -y install openssl-devel

# Add test user and switch to it
RUN adduser cppyy-test
USER cppyy-test

# Go to home dir
ENV HOME /home/cppyy-test
WORKDIR $HOME

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

# Configure pyenv
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH

# Install newer Python versions
RUN pyenv install 2.7.13
RUN pyenv install 2.7.14

# Add test file and script
ADD test.py test.py
ADD run_test.sh run_test.sh

# Run test
CMD [ "bash", "./run_test.sh" ]

