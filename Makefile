# COLORS
GREEN := "\033[32m"
YELLOW := "\033[33m"
BLUE := "\033[34m"
NC := "\033[0m"

# VARIABLES
NETWORK_NAME := "openumbrella"

DB_IMAGE_NAME := "custom-mysql"
DB_CONTAINER_NAME := "custom-mysql"

BACKEND_IMAGE_NAME := "openumbrella"
BACKEND_CONTAINER_NAME := "openumbrella"

# COMMANDS
all:
	@echo $(BLUE)🐋 Docker containers are starting... $(NC)
	@docker compose up --build
	@echo $(GREEN)✅ Successfully started! $(NC)
.PHONY: all

dev: stop network db backend
	@echo $(BLUE)🚧 Development MySQL container is starting... $(NC)
	@if [ ! -z $$(docker ps -aqf name=${DB_CONTAINER_NAME}) ]; then \
    	docker rm -f ${DB_CONTAINER_NAME}; \
	fi
	@docker run -d \
				--name ${DB_CONTAINER_NAME} \
				--network ${NETWORK_NAME} \
				--env-file ./.env.db \
				${DB_IMAGE_NAME}

	sleep 5

	@echo $(BLUE)🚧 Development backend container is starting... $(NC)
	@if [ ! -z $$(docker ps -aqf name=${BACKEND_CONTAINER_NAME}) ]; then \
    	docker rm -f ${BACKEND_CONTAINER_NAME}; \
	fi
	@docker run -d \
				--name ${BACKEND_CONTAINER_NAME} \
				--network ${NETWORK_NAME} \
				--env-file ./sql_app/.env \
				-p 3000:3000 \
				${BACKEND_IMAGE_NAME}
.PHONY: dev

# Check if the network already exists
network:
	@echo "Checking if the network exists..."
	@if [ -z $$(docker network ls -q -f name=${NETWORK_NAME}) ]; then \
		echo $(BLUE)🌐 Creating network... $(NC); \
		docker network create $(NETWORK_NAME); \
	else \
		echo $(BLUE)🌐 Network already exists... $(NC); \
	fi
.PHONY: network

# Build backend image if it doesn't exist
backend:
	@if [ -z $$(docker images -q ${BACKEND_IMAGE_NAME}) ]; then \
		echo $(BLUE)🏞 Building backend image is starting... $(NC); \
		docker build -t ${BACKEND_CONTAINER_NAME} -f ./Dockerfile.backend .; \
	else \
		echo $(BLUE)🏞 Backend image already exists... $(NC); \
	fi
.PHONY: backend

# Build MySQL image if it doesn't exist
db:
	@if [ -z $$(docker images -q ${DB_IMAGE_NAME}) ]; then \
		echo $(BLUE)🏞 Building MySQL image is starting... $(NC); \
		docker build -t ${DB_CONTAINER_NAME} -f ./Dockerfile.mysql .; \
	else \
		echo $(BLUE)🏞 MySQL image already exists... $(NC); \
	fi
.PHONY: db

down:
	@docker-compose -f ./docker-compose.yml down
.PHONY: down

re: prune
	make all
.PHONY: re

prune: stop
	@echo $(BLUE)"docker system prune will be executed"$(NC)
	@docker system prune -a -f --volumes
.PHONY: prune

stop:
	@if [ $$(docker ps -q | wc -l) -gt 0 ]; then \
		echo $(BLUE)🛑 Stopping containers... $(NC); \
		docker stop $$(docker ps -q); \
	else \
		echo $(YELLOW)No running containers found. $(NC); \
	fi
.PHONY: stop
