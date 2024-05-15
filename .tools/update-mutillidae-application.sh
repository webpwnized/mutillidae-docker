#!/bin/bash
# This is a Bash script for updating the Mutillidae web application.
# It must be run from the 'mutillidae-docker' directory.

# Check if the 'www' container is running
if [ ! "$(docker ps -q -f name=www)" ]; then
    echo "";
    echo "The 'www' container is not running so the application cannot be updated on the container.";
    exit 1;
fi;

# Print a newline for better readability.
echo "";

# Inform the user about the update process.
echo "Updating the Mutillidae application installed in the running 'www' container.";

# Use 'docker exec' to execute commands inside the 'www' container.
# First, ensure Git is installed by running 'apt install git -y' within the container.
docker exec -it www sh -c "apt update; apt install git -y; cd /var/www/mutillidae; git pull"
