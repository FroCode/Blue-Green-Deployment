#!/bin/bash

#============================================================== By Frocode =======================================================

# blue_green_deploy.sh
# Automates blue-green deployment for a Dockerized application with Nginx

set -euo pipefail

# Default configuration
CONFIG_FILE="/etc/bluegreen/deploy.conf"
LOG_FILE="/var/log/bluegreen_deploy.log"
TIMEOUT=30

# Logging func
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Load config
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log "Configuration file $CONFIG_FILE not found, using defaults"
    fi

    : "${APP_NAME:?APP_NAME must be set}"
    : "${BLUE_PORT:?BLUE_PORT must be set}"
    : "${GREEN_PORT:?GREEN_PORT must be set}"
    : "${NGINX_CONF:?NGINX_CONF must be set}"
    : "${DOCKER_IMAGE:?DOCKER_IMAGE must be set}"
    : "${HEALTH_CHECK_URL:?HEALTH_CHECK_URL must be set}"
}

# Health check func
check_health() {
    local port=$1
    local url="${HEALTH_CHECK_URL/PORT/$port}"
    log "Checking health at $url"
    for ((i=0; i<TIMEOUT; i++)); do
        if curl --silent --fail "$url" > /dev/null; then
            log "Health check passed for $url"
            return 0
        fi
        sleep 1
    done
    log "Health check failed for $url"
    return 1
}

# Switch Nginx to new environment
switch_nginx() {
    local new_port=$1
    log "Updating Nginx to route traffic to port $new_port"
    cat <<EOF > "$NGINX_CONF"
server {
    listen 80;
    location / {
        proxy_pass http://localhost:$new_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
    if nginx -t; then
        systemctl reload nginx
        log "Nginx reloaded successfully"
    else
        log "Nginx configuration test failed"
        return 1
    fi
}

# Rollback to previous environment
rollback() {
    local old_port=$1
    local old_env=$2
    log "Rolling back to $old_env on port $old_port"
    switch_nginx "$old_port"
    docker stop "${APP_NAME}_${old_env}" || log "Failed to stop $old_env container"
    exit 1
}

main() {
    load_config
    log "Starting blue-green deployment for $APP_NAME"

    # Determine current and new environment
    current_port=$(grep -oP 'proxy_pass http://localhost:\K\d+' "$NGINX_CONF" || echo "$BLUE_PORT")
    new_port=$([ "$current_port" = "$BLUE_PORT" ] && echo "$GREEN_PORT" || echo "$BLUE_PORT")
    new_env=$([ "$new_port" = "$BLUE_PORT" ] && echo "blue" || echo "green")
    old_env=$([ "$new_env" = "blue" ] && echo "green" || echo "blue")

    log "Current environment on port $current_port, deploying $new_env on port $new_port"

    # Pull latest image
    log "Pulling Docker image $DOCKER_IMAGE"
    docker pull "$DOCKER_IMAGE" || {
        log "Failed to pull Docker image"
        exit 1
    }

    # Start new container
    log "Starting $new_env container on port $new_port"
    docker run -d --rm --name "${APP_NAME}_${new_env}" -p "$new_port:8080" "$DOCKER_IMAGE" || {
        log "Failed to start $new_env container"
        exit 1
    }

    # Wait for container to be healthy
    if ! check_health "$new_port"; then
        log "Deployment failed: $new_env container unhealthy"
        rollback "$current_port" "$old_env"
    fi

    # Switch traffic to new environment
    if ! switch_nginx "$new_port"; then
        log "Nginx switch failed, rolling back"
        rollback "$current_port" "$old_env"
    fi

    # Stop old container
    if docker ps -q -f name="${APP_NAME}_${old_env}" | grep -q .; then
        log "Stopping old $old_env container"
        docker stop "${APP_NAME}_${old_env}" || log "Failed to stop $old_env container"
    fi

    log "Deployment completed successfully"
}

main "$@"