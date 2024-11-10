#!/bin/bash
# Purpose: Start Docker containers defined in docker-compose.yml
# Usage: ./start-containers.sh [options] -f <compose-file>

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
    echo "Examples:"
    echo "  1. Start containers without initialization:"
    echo "     ./.tools/start-containers.sh --compose-file ./.build/docker-compose.yml"
    echo ""
    echo "  2. Rebuild containers and start them:"
    echo "     ./.tools/start-containers.sh --compose-file ./.build/docker-compose.yml --rebuild-containers"
    echo ""
    echo "  3. Start and initialize containers with an LDIF file:"
    echo "     ./.tools/start-containers.sh --compose-file ./.build/docker-compose.yml --initialize-containers --ldif-file ./.build/ldap/configuration/ldif/mutillidae.ldif"
    echo ""
    echo "  4. Run script unattended with initialization and rebuild:"
    echo "     ./.tools/start-containers.sh --compose-file ./.build/docker-compose.yml --initialize-containers --ldif-file ./.build/ldap/configuration/ldif/mutillidae.ldif --rebuild-containers --unattended"
    echo ""
    echo "  5. Run script with help option:"
    echo "     ./.tools/start-containers.sh --help"
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
        -h|--help) show_help; exit 0 ;;
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

# Start Docker containers, forcing a rebuild if required
print_message "Starting containers"
if [[ "$REBUILD_CONTAINERS" = true ]]; then
    docker compose --file "$COMPOSE_FILE" up --detach --build --force-recreate || handle_error "Failed to start Docker containers"
else
    docker compose --file "$COMPOSE_FILE" up --detach || handle_error "Failed to start Docker containers"
fi

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
        print_message "At least one of the LDAP entries already exists, but others were added where possible."
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
