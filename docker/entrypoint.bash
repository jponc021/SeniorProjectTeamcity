#! /bin/bash

echo "Waiting for mongo to be ready"
#no way to really know how long mongo will take to be ready
sleep 120

node /Code/server.js
