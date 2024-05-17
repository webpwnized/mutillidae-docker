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
fi

# Clean up Docker resources
print_message "Cleaning up Docker resources for Mutillidae"

# Stop and remove all containers
print_message "Stopping and removing all containers"
docker stop $(docker ps -a -q) || handle_error "Failed to stop containers"
docker rm $(docker ps -a -q) || handle_error "Failed to remove containers"

# Remove all images
print_message "Removing all images"
docker rmi $(docker images -a -q) || handle_error "Failed to remove images"

# Prune containers, images, volumes, networks
print_message "Pruning containers, images, volumes, networks"
docker container prune -f || handle_error "Failed to prune containers"
docker image prune --all -f || handle_error "Failed to prune images"
docker volume prune -f || handle_error "Failed to prune volumes"
docker network prune -f || handle_error "Failed to prune networks"

# System-wide prune
print_message "Pruning system"
docker system prune --all --volumes -f || handle_error "Failed to prune system"

# Success message
print_message "Docker resources for Mutillidae cleaned up successfully"
