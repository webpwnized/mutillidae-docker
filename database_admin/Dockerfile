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
# Remove the apt-get lists after installation
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Open port 80 to the webserver
EXPOSE 80
