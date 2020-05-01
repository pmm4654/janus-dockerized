FROM ubuntu:18.04
RUN apt-get update
RUN apt-get update && apt-get install libmicrohttpd-dev libjansson-dev \
	libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
	libconfig-dev pkg-config gengetopt libtool automake gtk-doc-tools \
	cmake --yes
RUN apt-get install git --yes
RUN git clone https://gitlab.freedesktop.org/libnice/libnice
# RUN apt-get install gtk-doc-tools --yes
RUN cd libnice
WORKDIR /libnice
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make && make install

# next steps here
# https://github.com/meetecho/janus-gateway
# docker build . -t stuff

WORKDIR /
RUN git clone https://libwebsockets.org/repo/libwebsockets
WORKDIR /libwebsockets
RUN mkdir build
WORKDIR /libwebsockets/build
# # # See https://github.com/meetecho/janus-gateway/issues/732 re: LWS_MAX_SMP
RUN cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
RUN make && make install

RUN apt-get install libnanomsg-dev --yes

# install required version of libsrtp (.= 1.5.0) - ubuntu doesn't have it in the apt repository at the right version
WORKDIR /
RUN apt-get install wget
RUN wget github.com/cisco/libsrtp/archive/2_1_x_throttle.tar.gz
RUN tar xf 2_1_*.tar.gz && rm 2_1_*.tar.gz

WORKDIR /libsrtp-2_1_x_throttle
RUN ./configure --prefix=/usr
RUN make shared_library
RUN make install


WORKDIR /
RUN git clone https://github.com/meetecho/janus-gateway.git
WORKDIR /janus-gateway
RUN sh autogen.sh
RUN ./configure --prefix=/opt/janus
RUN make && make install

RUN make configs



