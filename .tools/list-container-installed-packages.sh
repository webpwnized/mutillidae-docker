#!/bin/bash

for i in $(docker ps --quiet); do 
    echo "";
    echo "--------------"; 
    echo $i; 
    echo "--------------"; 
    echo ""; 
    docker exec $i dpkg -l; 
done;
