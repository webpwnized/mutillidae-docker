# webpwnized/mutillidae:ldap

# Not an official repo
# Documentation: https://hub.docker.com/r/osixia/openldap
# Source: https://github.com/osixia/docker-openldap
# Uploading the Mutillidae LDIF data: ldapadd -c -x -D "cn=admin,dc=mutillidae,dc=localhost" -w mutillidae -H ldap:// -f mutillidae.ldif

FROM osixia/openldap:latest

# Set up the LDAP configuration
ENV LDAP_ORGANISATION="Mutillidae Inc"
ENV LDAP_DOMAIN="mutillidae.localhost"
ENV LDAP_BASE_DN="dc=mutillidae,dc=localhost"
ENV LDAP_ADMIN_PASSWORD="mutillidae"
ENV LDAP_CONFIG_PASSWORD="mutillidae"
ENV LDAP_TLS="false"

# Patch the container
# RUN apt update && \
#     apt -y upgrade && \
#     apt -y autoremove && \
#     apt clean
