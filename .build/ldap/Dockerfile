# Container image: webpwnized/mutillidae:ldap
# From project root, build with: 
#   docker build --file .build/ldap/Dockerfile --tag webpwnized/mutillidae:ldap .build/ldap/
#   
#       docker build: This is the command to build a Docker image.
#       --file .build/ldap/Dockerfile: This specifies the path to the Dockerfile you want to use. In this case, it's .build/ldap/Dockerfile.
#       --tag webpwnized/mutillidae:ldap: This tags the resulting Docker image with a name (webpwnized/mutillidae) and a tag (ldap).
#       .: This is the build context. It indicates the directory to be used for the build process. The Docker daemon will send this directory's contents to the Docker engine. In this case, the dot represents the current directory.
#
# From project root, run with:
#   docker compose -f .build/docker-compose.yml up --build --detach
#       docker-compose: This is the Docker Compose command-line tool used for managing multi-container Docker applications.
#       --file .build/docker-compose.yml: This option (--file or -f) specifies the path to the docker-compose.yml file. In this case, it’s located at .build/docker-compose.yml.
#       up: This subcommand tells Docker Compose to create and start the containers defined in the docker-compose.yml file. If the containers do not exist, they will be created. If they already exist, they will be started.
#       --detach: This option (--detach or -d) runs the containers in the background (detached mode). When you use this option, Docker Compose will start the containers and return control to the terminal, allowing you to continue using it for other commands or tasks.

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

# Commented out because patching caused issues
# Patch the container
# Remove the apt-get lists after installation
# RUN apt-get update && \
#    apt-get -y upgrade && \
#    apt-get -y autoremove && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

