#!/bin/bash
CMD=$1

case $CMD in
  (start)
    export PATH=$JAVA_HOME/bin:$PATH
    export SPARK_HOME=$CDH_SPARK_HOME
    export HADOOP_HOME=${HADOOP_HOME:-$CDH_HADOOP_HOME}
    export HADOOP_CONF_DIR=$CDH_YARN_HOME/etc/hadoop/
    export LIVY_CONF_DIR=`pwd`/livy-conf
    echo "Starting the Livy server"
    exec env LIVY_SERVER_JAVA_OPTS="-Dlogback.configurationFile=`pwd`/logback.xml -Dlogback.debug=true" CLASSPATH=`hadoop classpath` $LIVY_HOME/bin/livy-server
    ;;
  (*)
    echo "Don't understand [$CMD]"
    ;;
esac