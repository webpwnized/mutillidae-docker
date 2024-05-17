#!/bin/bash
# Purpose: Start Docker containers defined in docker-compose.yml
# Usage: ./start-containers.sh [options]
# Description: This script is used to start and optionally initialize the containers.
# The script must be run from the mutillidae-docker directory.

# Function to print messages with a timestamp
print_message() {
    echo ""
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to handle errors
handle_error() {
    print_message "Error: $1"
    exit 1
}

# Function to display help message
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --initialize          Initialize the containers after starting them."
    echo "  -u, --unattended          Run the script unattended without waiting for user input."
    echo "  -l, --ldif-file <path>    Specify the path to the LDIF file (required with --initialize)."
    echo "  -h, --help                Display this help message."
    echo ""
    echo "Description:"
    echo "This script is used to start and optionally initialize the containers."
    echo "The script must be run from the mutillidae-docker directory."
    echo ""
    echo "When run without options, the script starts the Docker containers defined in"
    echo "docker-compose.yml and waits for user input before clearing the screen."
    echo ""
    echo "When the --initialize option is provided, the script will:"
    echo "  1. Start the Docker containers."
    echo "  2. Wait for the database to start."
    echo "  3. Request the database to be built."
    echo "  4. Upload the specified LDIF file to the LDAP directory server."
    echo ""
    echo "When the --unattended option is provided, the script will not wait for user"
    echo "input and will not clear the screen after execution."
    echo ""
    echo "Examples:"
    echo "  Start containers without initialization:"
    echo "    $0"
    echo ""
    echo "  Start containers and initialize them:"
    echo "    $0 --initialize --ldif-file /path/to/ldif"
    echo ""
    echo "  Run script unattended:"
    echo "    $0 --unattended"
    echo ""
    echo "  Run script with initialization and unattended:"
    echo "    $0 --initialize --ldif-file /path/to/ldif --unattended"
    exit 0
}

# Parse options
INITIALIZE_CONTAINERS=false
UNATTENDED=false
LDIF_FILE=""

# Loop through the command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--initialize) INITIALIZE_CONTAINERS=true ;;
        -u|--unattended) UNATTENDED=true ;;
        -l|--ldif-file) 
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                LDIF_FILE="$2"
                shift
            else
                print_message "Error: --ldif-file requires a non-empty option argument."
                show_help
                exit 1
            fi ;;
        -h|--help) show_help ;;
        *) print_message "Unknown parameter passed: $1"
           show_help
           exit 1 ;;
    esac
    shift
done

# If initialization is required, ensure the LDIF file is provided
if [ "$INITIALIZE_CONTAINERS" = true ] && [ -z "$LDIF_FILE" ]; then
    print_message "Error: The --ldif-file option is required when using --initialize."
    show_help
    exit 1
fi

# Remove all current containers and container images if specified
if [ "$INITIALIZE_CONTAINERS" = true ]; then
    print_message "Removing all existing containers and container images"
    docker-compose -f docker-compose.yml down --rmi all -v || handle_error "Failed to remove existing containers and images"
fi

# Start Docker containers
print_message "Starting containers"
docker-compose -f docker-compose.yml up -d || handle_error "Failed to start Docker containers"

# Check if containers need to be initialized
if [ "$INITIALIZE_CONTAINERS" = true ]; then
    # Wait for the database container to start
    print_message "Waiting for database to start"
    sleep 10

    # Request database to be built
    print_message "Requesting database be built"
    curl -sS http://mutillidae.localhost/set-up-database.php || handle_error "Failed to set up the database"

    # Upload LDIF file to LDAP directory server
    print_message "Uploading LDIF file to LDAP directory server"
    ldapadd -c -x -D "cn=admin,dc=mutillidae,dc=localhost" -w mutillidae -H ldap:// -f "$LDIF_FILE"
    status=$?
    if [ $status -eq 0 ]; then
        print_message "LDAP entries added successfully."
    elif [ $status -eq 68 ]; then
        print_message "LDAP entry already exists."
    else
        handle_error "LDAP add operation failed with status: $status"
    fi

    # Check if the script should run unattended
    if [ "$UNATTENDED" = false ]; then
        # Wait for the user to press Enter key before continuing
        read -p "Press Enter to continue or <CTRL>-C to stop" </dev/tty

        # Clear the screen
        clear
    fi
fi
