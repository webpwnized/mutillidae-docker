# webpwnized/mutillidae:database

# Start with latest version of MySQL official
FROM mysql:debian

# Set the root password for MySQL server
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Add the public key from the MySQL repository
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

# Patch the container
RUN apt update
RUN apt -y upgrade
