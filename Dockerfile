FROM ubuntu:latest
MAINTAINER rjcoupe@gmail.com
ARG MONGO_VERSION='v2.6.3'
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
RUN mkdir -p /var/log/mongodb/

COPY ./generate_certs.sh /generate_certs.sh
RUN sh /generate_certs.sh

COPY ./mongo.yaml /config/mongo.yaml

RUN mkdir -p /var/downloads
WORKDIR /var/downloads
RUN git clone git://github.com/mongodb/mongo.git
RUN pwd
RUN ls -al
WORKDIR /var/downloads/mongo

RUN git checkout $MONGO_VERSION

RUN mkdir -p /usr/local/bin
RUN cd /var/downloads/mongo
RUN scons mongod --ssl --64 --release --no-glibc-check -j$CORES_AVAILABLE --disable-warnings-as-errors mongod
RUN cp /var/downloads/mongo/build/opt/mongo/mongod /usr/local/bin
RUN rm -rf /var/downloads

EXPOSE 27017

ENTRYPOINT ["/usr/local/bin/mongod", "--config", "/config/mongo.yaml"]

# Cleanup to minimise the image size
RUN apt-get remove -y --purge git-core scons \
    && apt-get autoremove -y --purge \
    && apt-get clean autoclean
