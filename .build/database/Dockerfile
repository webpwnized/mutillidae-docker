# Container image: webpwnized/mutillidae:database
# From project root, build with: 
#   docker build --file .build/database/Dockerfile --tag webpwnized/mutillidae:database .build/database/
#       docker build: This is the command to build a Docker image.
#       --file .build/database/Dockerfile: This specifies the path to the Dockerfile you want to use. In this case, it's .build/database/Dockerfile.
#       --tag webpwnized/mutillidae:database: This tags the resulting Docker image with a name (webpwnized/mutillidae) and a tag (database).
#       .: This is the build context. It indicates the directory to be used for the build process. The Docker daemon will send this directory's contents to the Docker engine. In this case, the dot represents the current directory.
#
# From project root, run with:
#   docker compose -f .build/docker-compose.yml up --build --detach
#       docker compose: This is the Docker Compose command-line tool used for managing multi-container Docker applications.
#       --file .build/docker-compose.yml: This option (--file or -f) specifies the path to the docker-compose.yml file. In this case, it’s located at .build/docker-compose.yml.
#       up: This subcommand tells Docker Compose to create and start the containers defined in the docker-compose.yml file. If the containers do not exist, they will be created. If they already exist, they will be started.
#       --detach: This option (--detach or -d) runs the containers in the background (detached mode). When you use this option, Docker Compose will start the containers and return control to the terminal, allowing you to continue using it for other commands or tasks.

# Start with latest version of MariaDB official image
FROM mariadb:latest

# Set environment variable for MySQL root password
ENV MYSQL_ROOT_PASSWORD="mutillidae"

# Combine apt-get commands and handle failures gracefully
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* || true
