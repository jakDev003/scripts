# This script is used to clean up Docker resources including containers, images, networks, and volumes.
# It is useful for freeing up disk space and removing unused Docker resources.
# Below is a detailed description of each command used in the script along with examples.

# Remove all unused containers, networks, images (both dangling and unreferenced), and optionally volumes.
# The --all flag removes all unused images not just dangling ones.
# The --force flag bypasses confirmation prompts.
# The --volumes flag removes all unused volumes.
docker system prune --all --force --volumes

# Example:
# docker system prune --all --force --volumes
# This command will remove all unused containers, networks, images, and volumes without asking for confirmation.

# Stop all running containers.
# The $(docker ps -q -a) command returns the IDs of all containers (both running and stopped).
docker stop $(docker ps -q -a)

# Example:
# docker stop $(docker ps -q -a)
# This command will stop all running containers.

# Remove all containers.
# The $(docker ps -q -a) command returns the IDs of all containers (both running and stopped).
docker rm $(docker ps -q -a)

# Example:
# docker rm $(docker ps -q -a)
# This command will remove all containers.

# Remove all images.
# The $(docker images -qa) command returns the IDs of all images.
docker rmi $(docker images -qa)

# Example:
# docker rmi $(docker images -qa)
# This command will remove all images.

# Remove dangling images.
# The -f flag forces the removal of the images.
docker image prune -f

# Example:
# docker image prune -f
# This command will remove all dangling images.

# Remove all volumes.
# The $(docker volume ls -q) command returns the names of all volumes.
docker volume rm $(docker volume ls -q)

# Example:
# docker volume rm $(docker volume ls -q)
# This command will remove all volumes.

# Remove dangling volumes.
docker volume prune

# Example:
# docker volume prune
# This command will remove all dangling volumes.

# Remove all networks.
# The $(docker network ls -q) command returns the IDs of all networks.
docker network rm $(docker network ls -q)

# Example:
# docker network rm $(docker network ls -q)
# This command will remove all networks.

# Remove dangling networks.
docker network prune

# Example:
# docker network prune
# This command will remove all dangling networks.