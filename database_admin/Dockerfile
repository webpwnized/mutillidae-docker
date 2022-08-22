# webpwnized/mutillidae:database_admin

# Start with phpmyadmin official image
# Documentation: https://hub.docker.com/_/phpmyadmin
FROM phpmyadmin:latest

# The name of the database container
ENV PMA_HOST="database"

# Create credentials
ENV MYSQL_ROOT_PASSWORD="mutillidae"
ENV PMA_USER="root"
ENV PMA_PASSWORD="mutillidae"

# Patch the container
RUN apt update && \
    apt -y upgrade && \
    apt -y autoremove && \
    apt clean

# Open port 80 to the webserver
EXPOSE 80
