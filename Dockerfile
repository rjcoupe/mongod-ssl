FROM ubuntu:latest
MAINTAINER rcoupe@sorensonmedia.com

RUN apt-get update && apt-get -y install \
  build-essential \
  git-core \
  scons \
  libssl-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-system-dev \
  libboost-thread-dev

RUN mkdir -p /var/downloads \
    && cd /var/downloads \
    && git clone --verbose git://github.com/mongodb/mongo.git \
    && cd /var/downloads/mongo
WORKDIR /var/downloads/mongo

RUN git checkout v3.4

RUN mkdir -p /usr/local/bin
RUN cd /var/downloads/mongo \
 && scons mongod --ssl -j8 --disable-warnings-as-errors all \
 && cp /var/downloads/mongo/build/linux2/64/ssl/mongo/mongod /usr/local/bin \
 && rm -rf /var/downloads

RUN mkdir -p /data/db
RUN mkdir -p /var/log/mongo.log

ENTRYPOINT ["/usr/local/bin/mongod", "--config", "/config/mongo.yaml"]

# Cleanup
RUN apt-get remove -y --purge git-core scons \
    && apt-get autoremove -y --purge \
    && apt-get clean autoclean