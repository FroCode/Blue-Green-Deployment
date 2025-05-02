Architecture Overview
Blue-Green Deployment
Blue-green deployment is a release management strategy that ensures zero-downtime updates by maintaining two identical environments:

Blue: The current production environment serving live traffic.
Green: The new environment with the updated application version.

Traffic is switched from blue to green once the green environment is validated, and the old blue environment is terminated or kept for rollback.
Components

Docker: Runs the application containers for blue and green environments.
Nginx: Acts as a reverse proxy to route traffic to the active environment.
Shell Script: Automates container management, health checks, and Nginx configuration updates.
Configuration File: Stores deployment settings for flexibility.
Health Check: Validates the new environment before switching traffic.

Workflow

Load Configuration: Reads settings from deploy.conf.
Determine Environments: Identifies the current (blue/green) and new environment based on Nginx configuration.
Pull Image: Downloads the latest Docker image.
Start New Container: Launches the new environment on the designated port.
Health Check: Validates the new container using the specified endpoint.
Switch Traffic: Updates Nginx to route traffic to the new environment.
Stop Old Container: Terminates the old environment's container.
Rollback (if needed): Reverts to the old environment on failure.

Diagram
[Client] --> [Nginx] --> [Blue Container (port 8080)]
                            |
                            v
                        [Green Container (port 8081)]

Benefits

Zero Downtime: Traffic switches instantly without user impact.
Safety: Health checks and rollback ensure reliability.
Flexibility: Configurable for different applications and environments.
Auditability: Detailed logs for tracking deployment events.

