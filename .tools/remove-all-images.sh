#!/bin/bash
# Purpose: Clean up Docker resources for Mutillidae application
# Usage: ./remove-all-images.sh [options]

# Function to print messages with a timestamp
print_message() {
    echo ""
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Function to display help message
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Display this help message."
    echo ""
    echo "Description:"
    echo "This script is used to clean up Docker resources for the Mutillidae application."
    echo "It stops and removes all containers, removes all images, and prunes all volumes and networks."
    exit 0
}

# Function to handle errors
handle_error() {
    print_message "Error: $1"
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
    exit 1
fi

# Clean up Docker resources
print_message "Cleaning up Docker resources for Mutillidae"

# Stop and remove all containers, with checks to ensure there are containers to stop
CONTAINERS=$(docker ps -a -q)
if [[ -n "$CONTAINERS" ]]; then
    print_message "Stopping and removing all containers"
    docker rm -f $CONTAINERS || handle_error "Failed to remove containers"
else
    print_message "No containers to remove"
fi

# Remove all images, with a check to ensure there are images to remove
IMAGES=$(docker images -a -q)
if [[ -n "$IMAGES" ]]; then
    print_message "Removing all images"
    docker rmi -f $IMAGES || handle_error "Failed to remove images"
else
    print_message "No images to remove"
fi

# Prune containers, images, volumes, and networks with error handling
print_message "Pruning containers, images, volumes, and networks"
docker container prune -f || true
docker image prune --all -f || true
docker volume prune -f || true
docker network prune -f || true

# System-wide prune to ensure complete cleanup
print_message "Performing system-wide prune"
docker system prune --all --volumes -f || handle_error "Failed to prune system"

# Success message
print_message "Docker resources for Mutillidae cleaned up successfully"
