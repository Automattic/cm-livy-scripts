#!/usr/bin/env bash

if [ "$1" = "" ]; then
    echo "Usage: $0 <VERSION>"
    echo
    echo "Example: $0 1.0"
    exit 1
fi

set -ex

JARNAME=LIVY2-$1.jar

rm -rf $JARNAME

# validate service description
java -jar ~/github/cloudera/cm_ext/validator/target/validator.jar -s ./csd-src/descriptor/service.sdl

jar -cvf ./$JARNAME -C ./csd-src .
echo "Created $JARNAME"