DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env

name = inception

all: up

# Start and build containers
up:
	mkdir -p /home/akuburas/data/mariadb
	mkdir -p /home/akuburas/data/wordpress
	chmod -R 777 /home/akuburas/data
	chmod -R 777 /home/akuburas/data/mariadb
	chmod -R 777 /home/akuburas/data/wordpress
	COMPOSE_BAKE=true docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

# Stop and remove containers
down:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

# Rebuild containers
re: fclean up

# Clean up unused Docker resources
clean: down
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down --remove-orphans
	docker system prune -f

# Full cleanup
fclean: down
	docker system prune --all --force --volumes
	docker network prune --force
	docker volume prune --force

# Follow logs of running containers
logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f


# Build Docker images
build:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) build

# Check the status of containers
status:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) ps

.PHONY: all up down re clean fclean logs  build status
