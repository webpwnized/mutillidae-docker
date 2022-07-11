# webpwnized/mutillidae:database

# Start with latest version of MySQL official
FROM mysql:8.0.29-debian

# Set the root password for MySQL server
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Patch the container
RUN apt update && apt -y upgrade
