#!/usr/bin/env bash

if [ "$1" = "" -o "$2" = "" ]; then
    echo "Usage: $0 <VERSION> <DISTRO>"
    echo
    echo "Example: $0 1.0 wheezy"
    exit 1
fi

set -ex

PARCEL_DIR=LIVY-$1
PARCEL=$PARCEL_DIR-$2.parcel

# Build Livy
[ ! -d ./livy ] && git clone https://github.com/cloudera/livy.git

cd ./livy

git checkout v0.2.0

mvn -DskipTests -Dspark.version=1.6.0-cdh5.9.0 -Dhadoop-version=2.6.0-cdh5.9.0 clean package

# Prepare parcel
cd ../

[ ! -d ./$PARCEL_DIR ] && rm -rf ./$PARCEL_DIR

mkdir -p ./$PARCEL_DIR/jars
mkdir -p ./$PARCEL_DIR/repl-jars
mkdir -p ./$PARCEL_DIR/rsc-jars

cp -r ./livy/bin ./$PARCEL_DIR/
cp -r ./livy/conf ./$PARCEL_DIR/
cp ./livy/server/target/jars/*.jar ./$PARCEL_DIR/jars/
cp ./livy/repl/target/jars/*.jar ./$PARCEL_DIR/repl-jars/
cp ./livy/rsc/target/jars/*.jar ./$PARCEL_DIR/rsc-jars/

cp -r parcel-src/meta $PARCEL_DIR/

sed -i -e "s/%VERSION%/$1/" ./$PARCEL_DIR/meta/*

# Validate and build parcel
java -jar ~/github/cloudera/cm_ext/validator/target/validator.jar -d ./$PARCEL_DIR

tar zcvhf ./$PARCEL $PARCEL_DIR

java -jar ~/github/cloudera/cm_ext/validator/target/validator.jar -f ./$PARCEL

# Remove parcel working directory
rm -rf ./$PARCEL_DIR

# Create parcel manifest
~/github/cloudera/cm_ext/make_manifest/make_manifest.py .
