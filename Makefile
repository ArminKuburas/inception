DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env

name = inception

all: up

# Start and build containers
up:
	mkdir -p /home/akuburas/data/mariadb
	mkdir -p /home/akuburas/data/wordpress
	sudo chmod -R 777 /home/akuburas/data
	sudo chmod -R 777 /home/akuburas/data/mariadb
	sudo chmod -R 777 /home/akuburas/data/wordpress
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
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down -v --remove-orphans
	docker volume rm wordpress mariadb || true
	docker system prune --all --force --volumes
	docker network prune --force
	sudo rm -rf /home/akuburas/data/mariadb
	sudo rm -rf /home/akuburas/data/wordpress

# Follow logs of running containers
logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f


# Build Docker images
build:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) build

# Check the status of containers
status:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) ps

add-host:
	@if ! grep -q "^127.0.0.1[[:space:]]\+akuburas.42.fr" /etc/hosts; then \
		echo "Adding akuburas.42.fr to /etc/hosts"; \
		echo "127.0.0.1 akuburas.42.fr" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "akuburas.42.fr already present in /etc/hosts"; \
	fi

.PHONY: all up down re clean fclean logs  build status add-host
