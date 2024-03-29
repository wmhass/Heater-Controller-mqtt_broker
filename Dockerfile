FROM debian:jessie

ENV MOSQUITTO_VERSION=1.5.1
ENV LIBWEBSOCKET_BRANCH=v2.0.0

RUN \
        set -x; \
        apt-get update && apt-get install -y --no-install-recommends \
                libc-ares-dev git libmysqlclient-dev libssl-dev uuid uuid-dev build-essential wget  ca-certificates \
                curl libcurl4-openssl-dev  libc-ares2 libcurl3 postgresql libpq-dev netcat cmake\
        && cd / \
        && git clone -b $LIBWEBSOCKET_BRANCH --single-branch https://github.com/warmcat/libwebsockets\
        && cd libwebsockets\
        && mkdir build\
        && cd build\
        && cmake ..\
        && make && make install\
        && ldconfig\
        && cd /tmp \
        && wget http://mosquitto.org/files/source/mosquitto-$MOSQUITTO_VERSION.tar.gz -O mosquitto.tar.gz \
        && wget http://mosquitto.org/files/source/mosquitto-$MOSQUITTO_VERSION.tar.gz.asc -O mosquitto.tar.gz.asc \
        && mkdir mosquitto-src && tar xfz mosquitto.tar.gz --strip-components=1 -C mosquitto-src \
        && cd mosquitto-src \
        && make WITH_SRV=yes WITH_MEMORY_TRACKING=no WITH_WEBSOCKETS=yes \
        && make install && ldconfig \
        && git clone https://github.com/jpmens/mosquitto-auth-plug.git \
        && cd mosquitto-auth-plug \
        && git checkout 7ff04a68c -b stable_branch \
        && cp config.mk.in config.mk \
        && sed -i "s/BACKEND_HTTP ?= no/BACKEND_HTTP ?= yes/" config.mk \
        && sed -i "s/BACKEND_MYSQL ?= yes/BACKEND_MYSQL ?= no/" config.mk \
        && sed -i "s/BACKEND_POSTGRES ?= no/BACKEND_POSTGRES ?= yes/" config.mk \
        && sed -i "s/CFG_LDFLAGS =/CFG_LDFLAGS = -lcares/" config.mk \
        && sed -i "s/MOSQUITTO_SRC =/MOSQUITTO_SRC = \/tmp\/mosquitto-src\//" config.mk \
        && make \
        && cp np /usr/bin/np \
        && mkdir /mqtt && cp auth-plug.so /mqtt/ \
        && cp auth-plug.so /usr/local/lib/ \
        && useradd -r mosquitto \
        && apt-get purge -y build-essential git wget ca-certificates \
        && apt-get autoremove -y \
        && apt-get -y autoclean \
        && rm -rf /var/cache/apt/* \
        && rm -rf  /tmp/*

VOLUME ["/var/lib/mosquitto"]

EXPOSE 1883 9001 8883

ADD ./config/mosquitto.conf /etc/mosquitto/config/mosquitto.conf
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod 777 /etc/mosquitto/config/mosquitto.conf
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


CMD ["mosquitto", "-c", "/etc/mosquitto/config/mosquitto.conf"]
