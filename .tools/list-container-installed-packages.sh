#!/bin/bash

# Function to log messages with timestamps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to list packages in a container
list_packages() {
    local container_id=$1
    local package_filter_cmd=$2

    echo ""
    echo "------------------------------"
    echo "Container ID: $container_id"
    echo "------------------------------"
    echo ""

    docker exec "$container_id" bash -c "$package_filter_cmd"
}

# Display usage instructions
display_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all     List all installed packages (default)"
    echo "  -u, --user    List only user-installed packages"
    echo "  -h, --help    Display this help message"
    exit 0
}

# Default behavior
list_user_packages=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--all) list_user_packages=false;;
        -u|--user) list_user_packages=true;;
        -h|--help) display_help;;
        *) log "Unknown parameter passed: $1"; display_help;;
    esac
    shift
done

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    log "Docker is not installed or not running."
    exit 1
fi

# Get the list of running containers
containers=$(docker ps --quiet)

if [ -z "$containers" ]; then
    log "No running Docker containers found."
    exit 0
fi

# Determine the package filter command based on the option selected
if [ "$list_user_packages" = true ]; then
    package_filter_cmd='comm -23 <(apt-mark showmanual | sort) <(apt list --installed 2>/dev/null | awk -F/ '\''{print $1}'\'' | sort)'
else
    package_filter_cmd='dpkg -l'
fi

# Loop through each container and list packages based on the option selected
for container_id in $containers; do
    if ! docker exec "$container_id" bash -c "$package_filter_cmd" &> /dev/null; then
        log "Failed to execute command in container $container_id. Skipping."
        continue
    fi

    list_packages "$container_id" "$package_filter_cmd"
done

log "Package listing completed."
