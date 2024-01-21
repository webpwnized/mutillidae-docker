# webpwnized/mutillidae:database

# Start with latest version of MySQL official
FROM mariadb:latest

# Set the root password for MySQL server
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Try to patch the container but do not fail if patching fails
# Remove the apt-get lists after installation
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; exit 0;
