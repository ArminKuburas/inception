.PHONY: build run stop clean

build:
	docker-compose -f srcs/docker-compose.yml build

run:
	docker-compose -f srcs/docker-compose.yml up -d

stop:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker-compose -f srcs/docker-compose.yml down --volumes --remove-orphans