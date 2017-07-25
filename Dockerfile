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
	ln -s /opt/jubatus_dev/core/latest /opt/jubatus_dev/core/core_target && \
	ln -s /opt/jubatus_dev/server/latest /opt/jubatus_dev/server/server_target


# install library for build
RUN apt-get -y update && \
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
	apt-get -y install mlocate

RUN cd /opt/jubatus_dev && wget http://download.jubat.us/files/source/jubatus_mpio/jubatus_mpio-0.4.1.tar.gz && \
	tar xzf jubatus_mpio-0.4.1.tar.gz && \
	cd jubatus_mpio-0.4.1 && \
	./configure && make && make install

RUN cd /opt/jubatus_dev && wget http://download.jubat.us/files/source/jubatus_msgpack-rpc/jubatus_msgpack-rpc-0.4.1.tar.gz && \
	tar xzf jubatus_msgpack-rpc-0.4.1.tar.gz && \
	cd jubatus_msgpack-rpc-0.4.1 && \
	./configure && make && make install

# checkoutのみ
RUN cd /opt/jubatus_dev && git clone https://github.com/jubatus/jubatus_core.git
#	cd jubatus_core && ./waf configure --prefix=~/jubatus/core/latest && \

# checkoutのみ jubatus_coreがないとconfigureできない
RUN cd /opt/jubatus_dev && git clone https://github.com/jubatus/jubatus.git


# set environment variables
# set base environment variable
ENV JUBATUS_HOME="/opt/jubatus_dev"
ENV JUBATUS_CORE_HOME="${JUBATUS_HOME}/core"
ENV JUBATUS_SERVER_HOME="${JUBATUS_HOME}/server"

ENV LD_LIBRARY_PATH="${JUBATUS_CORE_HOME}/latest/lib:${JUBATUS_SERVER_HOME}/latest/lib:/usr/local/lib"
ENV LDFLAGS="-L${JUBATUS_CORE_HOME}/latest/lib -L${JUBATUS_SERVER_HOME}/latest/lib -L/usr/local/lib"
ENV CPLUS_INCLUDE_PATH="${JUBATUS_CORE_HOME}/latest/include:${JUBATUS_SERVER_HOME}/latest/include:${JUBATUS_HOME}/include"
ENV PATH="${JUBATUS_CORE_HOME}/latest/bin:${JUBATUS_SERVER_HOME}/latest/bin:${PATH}"
ENV PKG_CONFIG_PATH="${JUBATUS_CORE_HOME}/latest/lib/pkgconfig:${JUBATUS_SERVER_HOME}/latest/lib/pkgconfig"

# set environment variables from /opt/jubatus/profile
# ENV JUBATUS_HOME /opt/jubatus
# ENV PATH ${JUBATUS_HOME}/bin:${PATH}
# ENV LD_LIBRARY_PATH ${JUBATUS_HOME}/lib:${LD_LIBRARY_PATH}
# ENV LDFLAGS -L${JUBATUS_HOME}/lib ${LDFLAGS}
# ENV CPLUS_INCLUDE_PATH ${JUBATUS_HOME}/include:${CPLUS_INCLUDE_PATH}
# ENV PKG_CONFIG_PATH ${JUBATUS_HOME}/lib/pkgconfig:${PKG_CONFIG_PATH}