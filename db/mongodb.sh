#!/usr/bin/env bash
# https://www.mongodb.com/download-center#community
package='mongodb-linux-x86_64-rhel70-3.4.4'
version='3.4.4'
dbpath='/usr/local/mongodb/db'
logspath='/usr/local/mongodb/logs'
startfile='/usr/local/mongodb/start.md'

wget https://fastdl.mongodb.org/linux/${package}.tgz
tar zxvf ${package}.tgz
mkdir -p /usr/local/mongodb/${version}
cp -rf ${package}/* /usr/local/mongodb/${version}
mkdir -p ${dbpath}
mkdir -p ${logspath}
touch ${logspath}/mongodb.logs

ln -sf /usr/local/mongodb/${version}/bin/mongod /usr/local/bin/mongod
ln -sf /usr/local/mongodb/${version}/bin/mongo /usr/local/bin/mongo

echo mongod --dbpath ${dbpath} --port 27017 --logpath ${logspath}/mongodb.logs --logappend > ${startfile}
