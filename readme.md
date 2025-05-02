Blue-Green Deployment Automation
A robust shell script-based solution for automating blue-green deployments in a Dockerized environment with Nginx as a reverse proxy. This project ensures zero-downtime deployments by managing container lifecycles, performing health checks, and dynamically updating Nginx configurations.
Features

Zero-Downtime Deployments: Seamlessly switch between blue and green environments.
Health Checks: Validates new containers before routing traffic.
Rollback Support: Automatically reverts to the previous environment on failure.
Configurable: Uses a configuration file for easy customization.
Logging: Comprehensive logs for debugging and auditing.
Modular Design: Includes helper scripts for setup and testing.

Prerequisites

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



Usage

Ensure your Docker image is available in a registry (e.g., Docker Hub).

Run the deployment script:
chmod +x scripts/blue_green_deploy.sh
sudo scripts/blue_green_deploy.sh


Monitor logs for deployment status:
tail -f /var/log/bluegreen_deploy.log



Configuration
Edit /etc/bluegreen/deploy.conf to customize:

APP_NAME: Name of the application.
BLUE_PORT/GREEN_PORT: Ports for blue/green environments.
NGINX_CONF: Path to Nginx configuration file.
DOCKER_IMAGE: Docker image name and tag.
HEALTH_CHECK_URL: Health check endpoint with PORT placeholder.

Testing
Run the test scripts to validate functionality:
chmod +x tests/test_deployment.sh tests/test_health_check.sh
./tests/test_deployment.sh
./tests/test_health_check.sh

