#!/bin/bash
CMD=$1

case $CMD in
  (start)
    export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-/etc/hadoop/conf}
    export SPARK_HOME=${SPARK_HOME:-$CDH_SPARK_HOME}
    export SPARK_CONF_DIR=${SPARK_CONF_DIR:-/etc/spark/conf}
    export LIVY_CONF_DIR=$CONF_DIR
    echo "Starting the Livy server"
    exec $LIVY_HOME/bin/livy-server
    ;;
  (*)
    echo "Don't understand [$CMD]"
    ;;
esac