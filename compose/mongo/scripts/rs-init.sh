#!/bin/bash

DELAY=25

mongosh <<EOF
var config = {
    "_id": "dbrs",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "pmongo:27017",
            "priority": 2
        },
        {
            "_id": 2,
            "host": "smongo:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
EOF

echo "****** Waiting for ${DELAY} seconds for replicaset configuration to be applied ******"

sleep $DELAY

mongosh --eval 'use admin' ./scripts/init.js
