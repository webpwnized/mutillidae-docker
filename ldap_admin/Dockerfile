# webpwnzied/mutillidae:ldap_admin

# Not an official repo
# Documentation: https://hub.docker.com/r/osixia/phpldapadmin
FROM osixia/phpldapadmin:latest

# The hostname of the ldap service configured in docker-compose.yml configuration
ENV PHPLDAPADMIN_LDAP_HOSTS="directory"

# Whether to use HTTPS (port 443) or HTTP (port 80) for web interface
ENV PHPLDAPADMIN_HTTPS="false"

# Patch the container
RUN apt update && \
    apt -y upgrade && \
    apt -y autoremove && \
    apt clean

# Open port 80 through the firewall
EXPOSE 80
