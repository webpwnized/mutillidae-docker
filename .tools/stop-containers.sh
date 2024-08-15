#!/bin/bash
# Purpose: Stop Docker containers defined in docker-compose.yml
# Usage: ./stop-containers.sh -f /path/to/docker-compose.yml [options]

# Function to print messages with a timestamp
print_message() {
    echo ""
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to display help message
show_help() {
    echo "Usage: $0 -f /path/to/docker-compose.yml [options]"
    echo ""
    echo "Options:"
    echo "  -f, --file     Path to the docker-compose.yml file (mandatory)."
    echo "  -h, --help     Display this help message."
    echo ""
    echo "Description:"
    echo "This script is used to stop Docker containers defined in docker-compose.yml."
    exit 0
}

# Function to handle errors
handle_error() {
    print_message "Error: $1"
    exit 1
}

# Initialize variables
compose_file=""

# Parse options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--file)
            shift
            compose_file=$1
            ;;
        -h|--help)
            show_help
            ;;
        *)
            handle_error "Unknown parameter passed: $1"
            ;;
    esac
    shift
done

# Check if compose file is provided
if [[ -z "$compose_file" ]]; then
    handle_error "The -f/--file option is mandatory. Use -h for help."
fi

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    handle_error "Docker is not installed or not in PATH. Please install Docker."
fi

# Stop Docker containers
print_message "Stopping and removing containers using $compose_file"
docker compose -f "$compose_file" down || handle_error "Failed to stop containers"

# Success message
print_message "Docker containers stopped successfully"
