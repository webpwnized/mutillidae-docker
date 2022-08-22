# webpwnized/mutillidae:database

# Start with latest version of MySQL official
FROM mysql:debian

# Set the root password for MySQL server
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Patch the container
RUN apt update && \
    apt -y upgrade && \
    apt -y autoremove && \
    apt clean

