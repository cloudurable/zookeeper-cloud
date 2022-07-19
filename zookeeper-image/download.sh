#!/usr/bin/env bash

set -e

# https://dlcdn.apache.org/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1.tar.gz
export MIRROR=https://dlcdn.apache.org
export MVN_URL=http://repo1.maven.org/maven2
export VERSION=3.7.1
export LOGBACK_VERSION=1.2.11
export LOGBACK_FILE="zookeeper-src/lib/logback-classic-$LOGBACK_VERSION.jar"


if [ ! -d "./zookeeper-src" ]; then
  curl "$MIRROR/zookeeper/zookeeper-$VERSION/apache-zookeeper-$VERSION-bin.tar.gz" \
    --output zookeeper.tgz
  tar -xvzf zookeeper.tgz
  mv apache-zookeeper-$VERSION-bin zookeeper-src
  rm zookeeper.tgz
else
  echo "zookeeper src already downloaded"
fi

if [ ! -f "$LOGBACK_FILE " ]; then

  curl "$MVN_URL/ch/qos/logback/logback-classic/$LOGBACK_VERSION/logback-classic-$LOGBACK_VERSION.jar" \
  --output "$LOGBACK_FILE"
  curl http://repo1.maven.org/maven2/ch/qos/logback/logback-core/1.2.3/logback-core-1.2.3.jar \
  --output zookeeper-src/lib/logback-core-$LOGBACK_VERSION.jar
else
    echo "logback jar already downloaded"
fi
