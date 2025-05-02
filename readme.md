# Blue-Green Deployment Automation
A robust shell script-based solution for automating blue-green deployments in a Dockerized environment with Nginx as a reverse proxy. This project ensures zero-downtime deployments by managing container lifecycles, performing health checks, and dynamically updating Nginx configurations.
Features

Zero-Downtime Deployments: Seamlessly switch between blue and green environments.
Health Checks: Validates new containers before routing traffic.
Rollback Support: Automatically reverts to the previous environment on failure.
Configurable: Uses a configuration file for easy customization.
Logging: Comprehensive logs for debugging and auditing.
Modular Design: Includes helper scripts for setup and testing.

# Prerequisites

OS: Ubuntu 20.04+ or similar Linux distribution
Tools: Docker, Nginx, curl
Permissions: Root or sudo access for setup
Docker Image: A Dockerized application with a health check endpoint (e.g., /health)



Run the setup script to install dependencies and configure the environment:
chmod +x scripts/setup_environment.sh
sudo scripts/setup_environment.sh


Copy the sample configuration file and customize it:
sudo cp config/deploy.conf /etc/bluegreen/deploy.conf
sudo nano /etc/bluegreen/deploy.conf



# Usage

Ensure your Docker image is available in a registry (e.g., Docker Hub).


