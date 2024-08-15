# Container image: webpwnized/mutillidae:ldap_admin
# From project root, build with: 
#   docker build --file .build/ldap_admin/Dockerfile --tag webpwnized/mutillidae:ldap_admin .build/ldap_admin/
#   
#       docker build: This is the command to build a Docker image.
#       --file .build/ldap_admin/Dockerfile: This specifies the path to the Dockerfile you want to use. In this case, it's .build/ldap_admin/Dockerfile.
#       --tag webpwnized/mutillidae:ldap_admin: This tags the resulting Docker image with a name (webpwnized/mutillidae) and a tag (ldap_admin).
#       .: This is the build context. It indicates the directory to be used for the build process. The Docker daemon will send this directory's contents to the Docker engine. In this case, the dot represents the current directory.
#
# From project root, run with:
#   docker compose -f .build/docker-compose.yml up --build --detach
#       docker-compose: This is the Docker Compose command-line tool used for managing multi-container Docker applications.
#       --file .build/docker-compose.yml: This option (--file or -f) specifies the path to the docker-compose.yml file. In this case, it’s located at .build/docker-compose.yml.
#       up: This subcommand tells Docker Compose to create and start the containers defined in the docker-compose.yml file. If the containers do not exist, they will be created. If they already exist, they will be started.
#       --detach: This option (--detach or -d) runs the containers in the background (detached mode). When you use this option, Docker Compose will start the containers and return control to the terminal, allowing you to continue using it for other commands or tasks.

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
    rm -rf /var/lib/apt/lists/* || true

# Open port 80 through the firewall
EXPOSE 80
