.PHONY: help build run test clean docker-build docker-up docker-down docker-logs

help:
	@echo "API Gateway - Available targets:"
	@echo "  make build          - Build the project with Gradle"
	@echo "  make run            - Run the application locally"
	@echo "  make test           - Run tests"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make docker-build   - Build Docker image"
	@echo "  make docker-up      - Start all services with docker-compose"
	@echo "  make docker-down    - Stop all services"
	@echo "  make docker-logs    - View docker-compose logs"
	@echo "  make docker-clean   - Remove all containers and volumes"

build:
	@echo "Building project..."
	./gradlew clean build -x test

run:
	@echo "Running application locally..."
	./gradlew bootRun

test:
	@echo "Running tests..."
	./gradlew test

clean:
	@echo "Cleaning build artifacts..."
	./gradlew clean

docker-build:
	@echo "Building Docker image..."
	docker build -t api-gateway:latest .

docker-up:
	@echo "Starting services with docker-compose..."
	docker-compose up -d

docker-down:
	@echo "Stopping services..."
	docker-compose down

docker-logs:
	@echo "Showing docker-compose logs..."
	docker-compose logs -f gateway

docker-clean:
	@echo "Removing containers and volumes..."
	docker-compose down -v
	docker rmi api-gateway:latest

docker-shell:
	@echo "Opening shell in gateway container..."
	docker exec -it api-gateway /bin/sh

test-gateway:
	@echo "Testing gateway routes..."
	@echo "Testing /service1 route..."
	curl -v http://localhost:8080/service1/status/200
	@echo "\nTesting /mock route..."
	curl -v http://localhost:8080/mock/__admin/

gradle-wrapper-update:
	@echo "Updating Gradle wrapper..."
	./gradlew wrapper --gradle-version 8.5
