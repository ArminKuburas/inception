.PHONY: build run stop clean generate-certs

generate-certs:
	srcs/requirements/nginx/tools/generate_certs.sh

build: generate-certs
	docker compose -f srcs/docker-compose.yml build

run:
	docker compose -f srcs/docker-compose.yml up -d

stop:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down --volumes --remove-orphans
