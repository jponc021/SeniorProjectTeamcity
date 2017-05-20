cd ~/senior-project/git/VIP-Website-6.0 && \
    cp ../senior-project-teamcity/docker/Dockerfile ./ && \
    cp ../senior-project-teamcity/docker/config ./ && \
    docker build -t pepote53/senior-project-vip-web:v0 . && \
    rm Dockerfile config
