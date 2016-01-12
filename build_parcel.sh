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
[ ! -d ./hue ] && git clone --depth 1 https://github.com/cloudera/hue.git

cd ./hue/apps/spark/java

mvn -DskipTests clean package

# Prepare parcel
cd ../../../..

[ ! -d ./$PARCEL_DIR ] && rm -rf ./$PARCEL_DIR

mkdir -p ./$PARCEL_DIR/lib

cp -r ./hue/apps/spark/java/bin ./$PARCEL_DIR/
cp -r ./hue/apps/spark/java/conf ./$PARCEL_DIR/
cp hue/apps/spark/java/livy-assembly/target/scala-2.10/*.jar ./$PARCEL_DIR/lib/

# Download logback jar
wget -O ./$PARCEL_DIR/lib/logback-classic.jar http://central.maven.org/maven2/ch/qos/logback/logback-classic/1.1.3/logback-classic-1.1.3.jar

# Set classpath
sed -i -e 's|livy-assembly/target/scala-2.10|lib|g' ./$PARCEL_DIR/bin/setup-classpath

cp -r parcel-src/meta $PARCEL_DIR/

sed -i -e "s/%VERSION%/$1/" ./$PARCEL_DIR/meta/*

# Add logback to classpath
echo "CLASSPATH=\"\$ASSEMBLY_DIR/logback-classic.jar:\$CLASSPATH\"" >> ./$PARCEL_DIR/bin/setup-classpath

# Validate and build parcel
java -jar ~/github/cloudera/cm_ext/validator/target/validator.jar -d ./$PARCEL_DIR

tar zcvhf ./$PARCEL $PARCEL_DIR

java -jar ~/github/cloudera/cm_ext/validator/target/validator.jar -f ./$PARCEL

# Remove parcel working directory
rm -rf ./$PARCEL_DIR

# Create parcel manifest
~/github/cloudera/cm_ext/make_manifest/make_manifest.py .
