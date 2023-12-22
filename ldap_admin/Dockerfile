# webpwnzied/mutillidae:ldap_admin

# Not an official repo
# Documentation: https://hub.docker.com/r/osixia/phpldapadmin
FROM osixia/phpldapadmin:latest

# The hostname of the ldap service configured in docker-compose.yml configuration
ENV PHPLDAPADMIN_LDAP_HOSTS="directory"

# Whether to use HTTPS (port 443) or HTTP (port 80) for web interface
ENV PHPLDAPADMIN_HTTPS="false"

# Try to patch the container but do not fail if patching fails
# Remove the apt-get lists after installation
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; exit 0;

# Open port 80 through the firewall
EXPOSE 80
