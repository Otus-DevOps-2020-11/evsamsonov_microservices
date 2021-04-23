#!/bin/bash

/usr/bin/mongod --fork --logpath /var/log/mongod.log --config /etc/mongodb.conf

cat /var/log/mongod.log

source /reddit/db_config

cd /reddit && puma || exit
