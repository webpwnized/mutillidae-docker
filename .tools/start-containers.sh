#!/bin/bash
# Purpose: Start Docker containers defined in docker-compose.yml
# Usage: ./start-containers.sh [options] -f <compose-file>
# Description: This script is used to start and optionally initialize the containers.

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
    echo "Usage: $0 [options] -f <compose-file>"
    echo ""
    echo "Options:"
    echo "  -f, --compose-file <path>  Specify the path to the docker-compose.yml file (required)."
    echo "  -i, --initialize-containers Initialize the containers after starting them."
    echo "  -r, --rebuild-containers   Rebuild the containers before starting them."
    echo "  -u, --unattended           Run the script unattended without waiting for user input."
    echo "  -l, --ldif-file <path>     Specify the path to the LDIF file (required with --initialize-containers)."
    echo "  -h, --help                 Display this help message."
    echo ""
    echo "Description:"
    echo "This script is used to start and optionally initialize the containers."
    echo "The script must be run from the mutillidae-docker directory."
    echo ""
    echo "When run without options, the script starts the Docker containers defined in"
    echo "the specified docker-compose.yml and waits for user input before clearing the screen."
    echo ""
    echo "When the --initialize-containers option is provided, the script will:"
    echo "  1. Start the Docker containers."
    echo "  2. Wait for the database to start."
    echo "  3. Request the database to be built."
    echo "  4. Upload the specified LDIF file to the LDAP directory server."
    echo ""
    echo "When the --rebuild-containers option is provided, the script will:"
    echo "  1. Remove all existing containers and container images."
    echo "  2. Start the Docker containers."
    echo ""
    echo "When the --unattended option is provided, the script will not wait for user"
    echo "input and will not clear the screen after execution."
    echo ""
    echo "Examples:"
    echo "  Start containers without initialization:"
    echo "    $0 --compose-file .build/docker-compose.yml"
    echo ""
    echo "  Start containers and initialize them:"
    echo "    $0 --compose-file .build/docker-compose.yml --initialize-containers --ldif-file .build/ldap/configuration/ldif/mutillidae.ldif"
    echo ""
    echo "  Rebuild containers and start them:"
    echo "    $0 --compose-file .build/docker-compose.yml --rebuild-containers"
    echo ""
    echo "  Run script unattended:"
    echo "    $0 --compose-file .build/docker-compose.yml --unattended"
    echo ""
    echo "  Run script with initialization and unattended:"
    echo "    $0 --compose-file .build/docker-compose.yml --initialize-containers --ldif-file .build/ldap/configuration/ldif/mutillidae.ldif --unattended"
    echo ""
    echo "  Run script with all available arguments:"
    echo "    $0 --compose-file .build/docker-compose.yml --rebuild-containers --initialize-containers --ldif-file .build/ldap/configuration/ldif/mutillidae.ldif --unattended"
    exit 0
}

# Parse options
INITIALIZE_CONTAINERS=false
REBUILD_CONTAINERS=false
UNATTENDED=false
LDIF_FILE=""
COMPOSE_FILE=""

# Loop through the command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--initialize-containers) INITIALIZE_CONTAINERS=true ;;
        -r|--rebuild-containers) REBUILD_CONTAINERS=true ;;
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
        -f|--compose-file)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                COMPOSE_FILE="$2"
                shift
            else
                print_message "Error: --compose-file requires a non-empty option argument."
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

# Ensure the compose file is provided
if [[ -z "$COMPOSE_FILE" ]]; then
    print_message "Error: The --compose-file option is required."
    show_help
    exit 1
fi

# If initialization is required, ensure the LDIF file is provided
if [[ "$INITIALIZE_CONTAINERS" = true && -z "$LDIF_FILE" ]]; then
    print_message "Error: The --ldif-file option is required when using --initialize-containers."
    show_help
    exit 1
fi

# Check if ldapadd is installed
if [[ "$INITIALIZE_CONTAINERS" = true ]]; then
    if ! command -v ldapadd &> /dev/null; then
        handle_error "ldapadd is not installed. Please install ldap-utils."
    fi
fi

# Remove all current containers and container images if specified
if [[ "$REBUILD_CONTAINERS" = true ]]; then
    print_message "Removing all existing containers and container images"
    docker compose --file "$COMPOSE_FILE" down --rmi all -v || handle_error "Failed to remove existing containers and images"
fi

# Start Docker containers
print_message "Starting containers"
docker compose --file "$COMPOSE_FILE" up --detach || handle_error "Failed to start Docker containers"

# Check if containers need to be initialized
if [[ "$INITIALIZE_CONTAINERS" = true ]]; then
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
    if [[ $status -eq 0 ]]; then
        print_message "LDAP entries added successfully."
    elif [[ $status -eq 68 ]]; then
        print_message "At least one of the LDAP entry already exists, but others added where possible."
    else
        handle_error "LDAP add operation failed with status: $status"
    fi

    # Check if the script should run unattended
    if [[ "$UNATTENDED" = false ]]; then
        # Wait for the user to press Enter key before continuing
        read -p "Press Enter to continue or <CTRL>-C to stop" </dev/tty

        # Clear the screen
        clear
    fi
fi
