#!/bin/bash

cd ~/senior-project/git/VIP-Website-6.0 && \
    cp ../senior-project-teamcity/docker/Dockerfile ./ && \
    cp ../senior-project-teamcity/docker/config ./ && \
    cp ../senior-project-teamcity/docker/entrypoint.bash ./ && \
    docker build -t pepote53/senior-project-vip-web:v1 . && \
    rm Dockerfile config entrypoint.bash