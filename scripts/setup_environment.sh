#!/bin/bash

#============================================================== By Frocode =======================================================


# setup_environment.sh
# Sets up the environment for blue-green deployment

set -euo pipefail

LOG_FILE="/var/log/bluegreen_setup.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

install_docker() {
    log "Installing Docker"
    if ! command -v docker >/dev/null 2>&1; then
        apt-get update
        apt-get install -y docker.io
        systemctl enable docker
        systemctl start docker
        log "Docker installed and started"
    else
        log "Docker already installed"
    fi
}

install_nginx() {
    log "Installing Nginx"
    if ! command -v nginx >/dev/null 2>&1; then
        apt-get update
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
        log "Nginx installed and started"
    else
        log "Nginx already installed"
    fi
}

configure_permissions() {
    log "Configuring permissions"
    mkdir -p /etc/bluegreen /var/log/bluegreen
    chown -R "$USER:$USER" /etc/bluegreen /var/log/bluegreen
    chmod -R 750 /etc/bluegreen /var/log/bluegreen
}

main() {
    log "Starting environment setup"
    install_docker
    install_nginx
    configure_permissions
    log "Environment setup completed"
}

main "$@"