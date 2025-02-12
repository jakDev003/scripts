#/bin/bash

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` [Ex: 'bash build_one.sh core' will run 'make build_core' with java home set to Java 8.]"
  exit 0
elif [ $# -eq 0 ]; then
  echo "Please enter an argument."
  exit 0
elif [ -z "$1" ]; then
  echo "Please enter an argument."
  exit 0
else
  make JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 build_${1}
fi

