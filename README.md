# Livy Spark Server parcel and CSD 

[Livy](https://github.com/cloudera/hue/tree/master/apps/spark/java#welcome-to-livy-the-rest-spark-server) is a wrapper 
around `spark-submit` to expose Spark as a REST service for integration with external applications. 

As it is still in beta, it is not included in the CDH bundle (as of CDH 5.5.1). This scripts in this repo creates both 
a Livy parcel and CSD for deploying it with Cloudera Manager.

## Prerequisites

Cloudera publishes a tool for making CM parcels. Install it on your workstation like so:

1. `mkdir -p ~/github/cloudera; cd ~/github/cloudera`
2. `git clone git@github.com:cloudera/cm_ext.git; cd cm_ext`
3. `mvn package`

## Instructions

### Parcel
1. Create the Livy parcel: `./build_parcel.sh <Version> <Distro>`. Example: `./build_parcel.sh 1.0 wheezy`
2. Serve the parcel: `./serve-parcel.sh`
3. In CM, add your machine to the list of `Remote Parcel Repository URLs` and click `Check for New Parcels`.
4. Download, Distribute, Activate. No need to restart the cluster as this parcel is not a dependency for any service.

### CSD
1. Create the CSD: `./build_csd.sh <Version>`. Example: ` ./build_csd.sh 1.0`. The CSD version is independent of the 
parcel version.
2. Copy the CSD jar (`LIVY-1.0.jar`) to CM host at `/opt/cloudera/csd/` and change the ownership of the jar to 
`﻿cloudera-scm:cloudera-scm`
3. Restart CM `﻿/etc/init.d/cloudera-scm-server restart`
4. Restart _﻿Cloudera Management Service_ from the CM UI.
5. Install the Livy service with _Add a service_ option in CM.


**Note**: Step 3 and 4 can be avoided by using the 
[experimental](https://github.com/cloudera/cm_ext/wiki/CSD-Developer-Tricks-and-Tools#partial-installation-development-mode-only) 
api for installing CSDs without restarting CM with a `GET https://CM:7180/cmf/csd/install?csdName=LIVY-1.0`

## Managing Livy
Livy has been defined as a javabased service in CSD which enables the basic monitoring and configuration relevant to 
java process through CM. Additional Livy parameters has also be added to the CSD to enable configuration management 
from CM. We are forcing logback as the logging implementation.

As of now, custom CSDs support declaring 
[custom montitoring metrics](https://github.com/cloudera/cm_ext/wiki/Service-Monitoring-Descriptor-Language-Reference) 
but no way to publish them from the service.