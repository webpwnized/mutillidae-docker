# webpwnized/mutillidae:database

# Start with latest version of MariaDB official image
FROM mariadb:latest

# Set environment variable for MySQL root password
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Combine apt-get commands and handle failures gracefully
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* || true
