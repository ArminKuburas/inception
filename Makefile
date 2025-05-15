DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all: up

#this will make, start and keep containers running
up: create_dirs
	docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

re: fclean up

clean: down
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down --remove-orphans
	docker system prune -f

fclean: down
	docker system prune --all --force --volumes
	docker network prune --force
	docker volume prune --force
	sudo rm -rf $(WORDPRESS_DATA_DIR) 
	sudo rm -rf $(MARIADB_DATA_DIR)

logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

create_dirs:
	mkdir -p $(WORDPRESS_DATA_DIR)
	mkdir -p $(MARIADB_DATA_DIR)
	chmod -R 777 /home/akuburas/data/mariadb /home/akuburas/data/wordpress

re: fclean up

.PHONY: all up down re clean fclean logs create_dirs
