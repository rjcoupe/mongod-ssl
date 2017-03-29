FROM ubuntu:latest
MAINTAINER rjcoupe@gmail.com
ARG MONGO_VERSION='v3.4'
ARG CORES_AVAILABLE=8

RUN apt-get update && apt-get -y install \
  build-essential \
  git-core \
  scons \
  libssl-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-system-dev \
  libboost-thread-dev

RUN mkdir -p /config
RUN mkdir -p /data/db
RUN mkdir -p /var/log/mongo.log

COPY ./generate_certs.sh /generate_certs.sh
RUN sh /generate_certs.sh

COPY ./mongo.yaml /config/mongo.yaml

RUN mkdir -p /var/downloads \
    && cd /var/downloads \
    && git clone --verbose git://github.com/mongodb/mongo.git \
    && cd /var/downloads/mongo
WORKDIR /var/downloads/mongo

RUN git checkout $MONGO_VERSION

RUN mkdir -p /usr/local/bin
RUN cd /var/downloads/mongo \
 && scons mongod --ssl -j$CORES_AVAILABLE --disable-warnings-as-errors mongod \
 && cp /var/downloads/mongo/build/linux2/64/ssl/mongo/mongod /usr/local/bin \
 && rm -rf /var/downloads

EXPOSE 27017

ENTRYPOINT ["/usr/local/bin/mongod", "--config", "/config/mongo.yaml"]

RUN apt-get remove -y --purge git-core scons \
    && apt-get autoremove -y --purge \
    && apt-get clean autoclean
