# base image
FROM ubuntu:14.04
MAINTAINER PFN & NTT <jubatus-team@googlegroups.com>

# install jubatus
# RUN echo "deb http://download.jubat.us/apt/ubuntu/trusty binary/" >> /etc/apt/sources.list.d/jubatus.list && \
# 	apt-get -y update && \
# 	apt-get --force-yes -y install jubatus

# make jubatus devel directory
RUN mkdir /opt/jubatus_dev && \ 
	mkdir /opt/jubatus_dev/core && \
	mkdir /opt/jubatus_dev/core/latest && \
	mkdir /opt/jubatus_dev/server && \
	mkdir /opt/jubatus_dev/server/latest && \
	ln -s /opt/jubatus_dev/core/latest /opt/jubatus_dev/core/target && \
	ln -s /opt/jubatus_dev/server/latest /opt/jubatus_dev/server/target && \
	mkdir /var/jubatus_dev

# set environment variables
# set base environment variable
ENV JUBATUS_HOME="/opt/jubatus_dev"
ENV JUBATUS_CORE_HOME="${JUBATUS_HOME}/core"
ENV JUBATUS_SERVER_HOME="${JUBATUS_HOME}/server"
ENV JUBATUS_CORE_BUILD="${JUBATUS_CORE_HOME}/target"
ENV JUBATUS_SERVER_BUILD="${JUBATUS_SERVER_HOME}/target"

ENV JUBATUS_DEV_HOME="/var/jubatus_dev"

ENV LD_LIBRARY_PATH="${JUBATUS_CORE_BUILD}/lib:${JUBATUS_SERVER_BUILD}/lib:/usr/local/lib"
ENV LDFLAGS="-L${JUBATUS_CORE_BUILD}/lib -L${JUBATUS_SERVER_BUILD}/lib -L/usr/local/lib"
ENV CPLUS_INCLUDE_PATH="${JUBATUS_CORE_BUILD}/include:${JUBATUS_SERVER_BUILD}/include:${JUBATUS_HOME}/include"
ENV PATH="${JUBATUS_CORE_BUILD}/bin:${JUBATUS_SERVER_BUILD}/bin:${PATH}"
ENV PKG_CONFIG_PATH="${JUBATUS_CORE_BUILD}/lib/pkgconfig:${JUBATUS_SERVER_BUILD}/lib/pkgconfig"

# install library for build
RUN	apt-get -y update && \
	apt-get -y install build-essential && \
	apt-get -y install git-core && \
	apt-get -y install pkg-config && \
	apt-get -y install libmsgpack-dev && \
	apt-get -y install libonig-dev && \
	apt-get -y install liblog4cxx10-dev && \
	apt-get -y install python
	
# install utility
RUN	apt-get -y update && \
	apt-get -y install wget && \
	apt-get -y install mlocate && \
	apt-get -y install python-dev && \
	wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN cd ${JUBATUS_DEV_HOME} && wget http://download.jubat.us/files/source/jubatus_mpio/jubatus_mpio-0.4.1.tar.gz && \
	tar xzf jubatus_mpio-0.4.1.tar.gz && \
	cd jubatus_mpio-0.4.1 && \
	./configure && make && make install

RUN cd ${JUBATUS_DEV_HOME} && wget http://download.jubat.us/files/source/jubatus_msgpack-rpc/jubatus_msgpack-rpc-0.4.1.tar.gz && \
	tar xzf jubatus_msgpack-rpc-0.4.1.tar.gz && \
	cd jubatus_msgpack-rpc-0.4.1 && \
	./configure && make && make install


# Jubatus core checkout & build & install
RUN cd  ${JUBATUS_DEV_HOME} && git clone https://github.com/jubatus/jubatus_core.git && \
	cd jubatus_core && ./waf configure --prefix=${JUBATUS_CORE_HOME}/target && \
	./waf build && ./waf install


# Jubatus Server checkout & build & install
RUN cd ${JUBATUS_DEV_HOME} && git clone https://github.com/jubatus/jubatus.git && \
	cd jubatus && ./waf configure --prefix=${JUBATUS_SERVER_HOME}/target && \
	./waf build && ./waf install

# Jubatus Example install
RUN  cd ${JUBATUS_DEV_HOME} && git clone https://github.com/jubatus/jubatus-example.git

# Jubatus Client
RUN pip install jubatus


# set environment variables from /opt/jubatus/profile
# ENV JUBATUS_HOME /opt/jubatus
# ENV PATH ${JUBATUS_HOME}/bin:${PATH}
# ENV LD_LIBRARY_PATH ${JUBATUS_HOME}/lib:${LD_LIBRARY_PATH}
# ENV LDFLAGS -L${JUBATUS_HOME}/lib ${LDFLAGS}
# ENV CPLUS_INCLUDE_PATH ${JUBATUS_HOME}/include:${CPLUS_INCLUDE_PATH}
# ENV PKG_CONFIG_PATH ${JUBATUS_HOME}/lib/pkgconfig:${PKG_CONFIG_PATH}