#/bin/bash

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` [Ex: 'bash build_all.sh' will run 'make build_all' with java home set to Java 8.]"
  exit 0
else
  make JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 build_all
fi

