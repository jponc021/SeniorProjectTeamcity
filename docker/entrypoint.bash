#! /bin/bash

echo "Waiting for mongo to be ready"
command="nc -z mongo 27017"
${command}
while [ $? -ne 0 ]; do
    ${command}
done
#no way to really know how long mongo will take to be ready
sleep 120