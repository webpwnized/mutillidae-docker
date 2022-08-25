#!/bin/bash

docker stop $(docker ps -a -q);
docker rm $(docker ps -a -q);
docker rmi $(docker images -a -q);
docker container prune -f;
docker image prune --all -f;
docker volume prune -f;
docker system prune --all --volumes -f;
