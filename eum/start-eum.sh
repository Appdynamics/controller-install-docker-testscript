#!/bin/sh

# start EUM MySQL Database
export JAVA_HOME=/home/appdynamics/EUM/jre
cd /home/appdynamics/EUM/orcha/orcha-master/bin
./orcha-master -d mysql.groovy -p ../../playbooks/mysql-orcha/start-mysql.orcha -o ../conf/orcha.properties -c local

# start EUM Processor
cd /home/appdynamics/EUM/eum-processor/
bin/eum.sh start
