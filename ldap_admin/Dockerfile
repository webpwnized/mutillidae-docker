# webpwnzied/mutillidae:ldap_admin

# Not an official repo
# Documentation: https://hub.docker.com/r/osixia/phpldapadmin
FROM osixia/phpldapadmin:latest

# Configuration
ENV PHPLDAPADMIN_LDAP_HOSTS="ldap"
ENV PHPLDAPADMIN_HTTPS="false"

# Patch the container
RUN apt update && apt upgrade

# Open port 80 through the firewall
EXPOSE 80
