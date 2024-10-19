#!/bin/bash
# This is a Bash script for updating the Mutillidae web application.
# It must be run from the 'mutillidae-docker' directory.

# Function to log messages to the console
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to display help message
show_help() {
    echo "Usage: $0 <branch>"
    echo ""
    echo "This script updates the Mutillidae web application from a specified Git branch."
    echo ""
    echo "Options:"
    echo "  <branch>       The name of the branch to update from (e.g., feature/my-feature)."
    echo ""
    echo "Description:"
    echo "  The script updates the Mutillidae application running inside the 'www' Docker container."
    echo "  It clones the specified branch of the Mutillidae repository, replaces the current source,"
    echo "  and updates the application configuration to connect to the correct database and LDAP server."
    echo ""
    echo "Example:"
    echo "  $0 feature/my-new-feature"
    exit 0
}

# Function to check if the 'www' container is running
is_container_running() {
    local container_name="www"
    if [ "$(docker ps -q -f name=$container_name)" ]; then
        return 0  # Container is running
    else
        return 1  # Container is not running
    fi
}

# Function to check the exit code and return 1 if not 0
check_exit_code() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        return 1
    fi
    return 0
}

# Function to run a command inside the container with logging
run_command_in_container() {
    local container_name=$1
    local command=$2
    local step_description=$3

    log "Executing step: $step_description"
    docker exec -it $container_name sh -c "$command"
    check_exit_code || { log "Step failed: $step_description"; exit 1; }
    log "Step succeeded: $step_description"
}

# Function to update Mutillidae application inside the container
update_mutillidae() {
    local container_name="www"
    local temp_dir="/tmp/mutillidae"
    local mutillidae_src="/var/www/mutillidae"
    local database_host="database"
    local database_username="root"
    local database_password="mutillidae"
    local database_name="mutillidae"
    local database_port="3306"
    local ldap_server_hostname="directory"
    local branch=$1

    log "Updating Mutillidae application in the running '$container_name' container."

    # Install Git and clone the Mutillidae repository
    run_command_in_container $container_name "apt update && apt install --no-install-recommends -y git" "Install Git and update APT"

    # Remove existing Mutillidae source directory and clone new code from the specified branch
    run_command_in_container $container_name "rm -rf $mutillidae_src; cd /tmp; git clone https://github.com/webpwnized/mutillidae.git $temp_dir" "Clone Mutillidae repository"

    # Checkout the specified branch in the cloned repository
    run_command_in_container $container_name "cd $temp_dir && git checkout $branch" "Checkout branch $branch"

    # Copy new source code to Mutillidae directory
    run_command_in_container $container_name "cp -r $temp_dir/src $mutillidae_src" "Copy Mutillidae source code"

    # Clean up temporary directory
    run_command_in_container $container_name "rm -rf $temp_dir" "Clean up temporary directory"

    # Remove the .htaccess file
    run_command_in_container $container_name "rm /var/www/mutillidae/.htaccess" "Remove the .htaccess file"

    # Update the database hostname
    run_command_in_container $container_name "sed -i \"s/define('DB_HOST', '127.0.0.1');/define('DB_HOST', '$database_host');/\" /var/www/mutillidae/includes/database-config.inc" "Update the database hostname"

    # Update the database username
    run_command_in_container $container_name "sed -i \"s/define('DB_USERNAME', 'root');/define('DB_USERNAME', '$database_username');/\" /var/www/mutillidae/includes/database-config.inc" "Update the database username"

    # Update the database password
    run_command_in_container $container_name "sed -i \"s/define('DB_PASSWORD', 'mutillidae');/define('DB_PASSWORD', '$database_password');/\" /var/www/mutillidae/includes/database-config.inc" "Update the database password"

    # Update the database name
    run_command_in_container $container_name "sed -i \"s/define('DB_NAME', 'mutillidae');/define('DB_NAME', '$database_name');/\" /var/www/mutillidae/includes/database-config.inc" "Update the database name"

    # Update the database port
    run_command_in_container $container_name "sed -i \"s/define('DB_PORT', 3306);/define('DB_PORT', $database_port);/\" /var/www/mutillidae/includes/database-config.inc" "Update the database port"
    
    # Update the LDAP server hostname
    run_command_in_container $container_name "sed -i 's/127.0.0.1/$ldap_server_hostname/' /var/www/mutillidae/includes/ldap-config.inc" "Update the LDAP server hostname"
        
    log "Mutillidae application update completed successfully."
}

# Main script logic
main() {
    if [ $# -ne 1 ]; then
        show_help
    fi

    local branch=$1

    if ! is_container_running; then
        log "The 'www' container is not running, so the application cannot be updated."
        exit 1
    fi

    update_mutillidae $branch
}

# Call the main function
main "$@"
