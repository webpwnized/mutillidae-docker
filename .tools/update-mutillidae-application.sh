#!/bin/bash
# Secure Mutillidae updater with getopt named option parsing

set -euo pipefail

# Log helper
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Show usage
show_help() {
    echo "Usage: $0 -b <branch>"
    echo ""
    echo "Options:"
    echo "  -b, --branch   Git branch name to deploy (required)"
    echo "  -h, --help     Show help and exit"
    echo ""
    echo "Example:"
    echo "  $0 -b feature/my-fix"
}

# Check if container is running
is_container_running() {
    local container_name="www"
    [ "$(docker ps -q -f name=$container_name)" ] && return 0 || return 1
}

# Run command in container
run_command_in_container() {
    local container_name=$1
    local command=$2
    local desc=$3

    log "Executing: $desc"
    docker exec -i "$container_name" sh -c "$command"
    [ $? -eq 0 ] || { log "Failed: $desc"; exit 1; }
    log "Success: $desc"
}

# Cleanup flag
CLEANUP_ENABLED=false

# Cleanup handler
cleanup() {
    if [ "$CLEANUP_ENABLED" = true ]; then
        local container_name="www"
        local temp_dir="/tmp/mutillidae"
        log "Running cleanup handler..."
        docker exec -i "$container_name" sh -c "rm -rf $temp_dir" || true
        log "Cleanup completed."
    fi
}

trap cleanup EXIT

# Update Mutillidae
update_mutillidae() {
    local container_name="www"
    local temp_dir="/tmp/mutillidae"
    local src_dir="/var/www/mutillidae"
    local branch=$1

    local db_host="database"
    local db_user="root"
    local db_pass="mutillidae"
    local db_name="mutillidae"
    local db_port="3306"
    local ldap_host="directory"

    log "Updating Mutillidae in '$container_name' with branch '$branch'"

    run_command_in_container "$container_name" "apt update && apt install --no-install-recommends -y git" "Install Git"

    run_command_in_container "$container_name" "rm -rf $temp_dir && cd /tmp && git clone https://github.com/webpwnized/mutillidae.git $temp_dir" "Clone repo"

    run_command_in_container "$container_name" "cd $temp_dir && git checkout $branch" "Checkout branch '$branch'"

    run_command_in_container "$container_name" "rm -rf $src_dir && cp -r $temp_dir/src $src_dir" "Replace source"

    run_command_in_container "$container_name" "rm -f $src_dir/.htaccess" "Remove .htaccess"

    run_command_in_container "$container_name" "sed -i \"s/define('DB_HOST', '127.0.0.1');/define('DB_HOST', '$db_host');/\" $src_dir/includes/database-config.inc" "Update DB_HOST"
    run_command_in_container "$container_name" "sed -i \"s/define('DB_USERNAME', 'root');/define('DB_USERNAME', '$db_user');/\" $src_dir/includes/database-config.inc" "Update DB_USERNAME"
    run_command_in_container "$container_name" "sed -i \"s/define('DB_PASSWORD', 'mutillidae');/define('DB_PASSWORD', '$db_pass');/\" $src_dir/includes/database-config.inc" "Update DB_PASSWORD"
    run_command_in_container "$container_name" "sed -i \"s/define('DB_NAME', 'mutillidae');/define('DB_NAME', '$db_name');/\" $src_dir/includes/database-config.inc" "Update DB_NAME"
    run_command_in_container "$container_name" "sed -i \"s/define('DB_PORT', 3306);/define('DB_PORT', $db_port);/\" $src_dir/includes/database-config.inc" "Update DB_PORT"

    run_command_in_container "$container_name" "sed -i 's/127.0.0.1/$ldap_host/' $src_dir/includes/ldap-config.inc" "Update LDAP hostname"

    log "Mutillidae update complete!"
}

# Main with getopt parsing
main() {
    local branch=""

    # Use getopt for -b/--branch and -h/--help
    OPTIONS=$(getopt -o b:h --long branch:,help -- "$@") || {
        show_help
        exit 1
    }

    eval set -- "$OPTIONS"

    while true; do
        case "$1" in
            -b|--branch)
                branch="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                show_help
                exit 1
                ;;
        esac
    done

    if [[ -z "$branch" ]]; then
        log "Error: --branch is required."
        show_help
        exit 1
    fi

    if ! is_container_running; then
        log "Error: 'www' container is not running."
        exit 1
    fi

    CLEANUP_ENABLED=true

    update_mutillidae "$branch"
}

main "$@"

