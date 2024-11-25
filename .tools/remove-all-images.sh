#!/bin/bash
# Purpose: Clean up all Docker resources for Mutillidae application
# Usage: ./remove-all-images.sh [options]

# Function to print messages with a timestamp
print_message() {
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
    echo "  -h, --help     Display this help message."
    echo ""
    echo "Description:"
    echo "This script stops and removes all Docker containers and images for the Mutillidae application, then prunes unused volumes and networks."
    exit 0
}

# Parse options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help ;;
        *) handle_error "Unknown parameter passed: $1" ;;
    esac
    shift
done

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    handle_error "Docker is not installed or not in PATH. Please install Docker."
fi

# Clean up all Docker resources
print_message "Cleaning up all Docker resources for Mutillidae"

# Stop and remove all containers
CONTAINERS=$(docker ps -a -q)
if [[ -n "$CONTAINERS" ]]; then
    print_message "Stopping and removing all containers"
    docker rm -f $CONTAINERS || handle_error "Failed to remove containers"
else
    print_message "No containers to remove"
fi

# Remove all images
IMAGES=$(docker images -a -q)
if [[ -n "$IMAGES" ]]; then
    print_message "Removing all images"
    docker rmi -f $IMAGES || handle_error "Failed to remove images"
else
    print_message "No images to remove"
fi

# Prune unused resources
print_message "Pruning unused volumes and networks"
docker volume prune -f || handle_error "Failed to prune volumes"
docker network prune -f || handle_error "Failed to prune networks"

# Success message
print_message "All Docker resources cleaned up successfully"
