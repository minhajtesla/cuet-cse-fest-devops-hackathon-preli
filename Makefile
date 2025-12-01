# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)

# Variables
MODE ?= dev
SERVICE ?= backend
ARGS ?=

# Determine Compose File based on Mode
ifeq ($(MODE), prod)
    COMPOSE_FILE := docker/compose.production.yaml
else
    COMPOSE_FILE := docker/compose.development.yaml
endif

# Main Commands
up:
	docker-compose -f $(COMPOSE_FILE) up -d $(ARGS)

down:
	docker-compose -f $(COMPOSE_FILE) down $(ARGS)

build:
	docker-compose -f $(COMPOSE_FILE) build $(ARGS)

logs:
	docker-compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

restart:
	docker-compose -f $(COMPOSE_FILE) restart $(ARGS)

shell:
	docker-compose -f $(COMPOSE_FILE) exec $(SERVICE) sh

ps:
	docker-compose -f $(COMPOSE_FILE) ps

# Convenience Aliases (Development):
dev-up:
	make up MODE=dev

dev-down:
	make down MODE=dev

dev-build:
	make build MODE=dev

dev-logs:
	make logs MODE=dev

dev-restart:
	make restart MODE=dev

dev-shell:
	make shell MODE=dev

dev-ps:
	make ps MODE=dev

backend-shell:
	make shell SERVICE=backend

gateway-shell:
	make shell SERVICE=gateway

mongo-shell:
	make shell SERVICE=mongodb

# Convenience Aliases (Production):
prod-up:
	make up MODE=prod

prod-down:
	make down MODE=prod

prod-build:
	make build MODE=prod

prod-logs:
	make logs MODE=prod

prod-restart:
	make restart MODE=prod

# Backend:
backend-build:
	cd backend && npm run build

backend-install:
	cd backend && npm install

backend-type-check:
	cd backend && npm run type-check

backend-dev:
	cd backend && npm run dev

# Database:
db-reset:
	docker-compose -f $(COMPOSE_FILE) down -v
	docker-compose -f $(COMPOSE_FILE) up -d mongodb

# Cleanup:
clean:
	docker-compose -f docker/compose.development.yaml down --remove-orphans
	docker-compose -f docker/compose.production.yaml down --remove-orphans

clean-all:
	docker-compose -f docker/compose.development.yaml down -v --rmi all --remove-orphans
	docker-compose -f docker/compose.production.yaml down -v --rmi all --remove-orphans

clean-volumes:
	docker volume prune -f

# Utilities:
status: ps

# Health checks
health:
	@echo "Checking Gateway health..."
	@curl -f http://localhost:5921/health || echo "Gateway is not responding"

health-backend:
	@echo "Checking Backend health via Gateway..."
	@curl -f http://localhost:5921/api/health || echo "Backend is not responding"

health-all:
	@echo "Running all health checks..."
	@make health
	@make health-backend

# Testing commands
test-create-product:
	@echo "Creating a test product..."
	@curl -X POST http://localhost:5921/api/products \
		-H 'Content-Type: application/json' \
		-d '{"name":"Test Product","price":99.99}'

test-get-products:
	@echo "Fetching all products..."
	@curl http://localhost:5921/api/products

test-security:
	@echo "Testing if backend is directly accessible (should fail)..."
	@curl http://localhost:3847/api/products || echo "Good! Backend is not directly accessible."

test-all:
	@echo "Running all tests..."
	@make health-all
	@sleep 2
	@make test-create-product
	@sleep 1
	@make test-get-products
	@sleep 1
	@make test-security

# Docker system cleanup
docker-clean:
	@echo "Cleaning up Docker system..."
	docker system prune -f

docker-clean-all:
	@echo "Cleaning up all Docker resources..."
	docker system prune -af --volumes

# Quick start commands
quick-start:
	@echo "Starting development environment..."
	@make dev-build
	@make dev-up
	@sleep 10
	@make health-all

quick-start-prod:
	@echo "Starting production environment..."
	@make prod-build
	@make prod-up
	@sleep 10
	@make health-all

# View container stats
stats:
	docker stats --no-stream

# Inspect services
inspect-backend:
	docker inspect backend-$(MODE)

inspect-gateway:
	docker inspect gateway-$(MODE)

inspect-mongodb:
	docker inspect mongodb-$(MODE)

# Network inspection
network-inspect:
	docker network inspect $(shell docker network ls --filter name=app-network -q)

# Volume inspection
volume-inspect:
	docker volume ls | grep mongo-data

# Help:
help:
	@echo "Usage: make [command] [MODE=dev|prod] [SERVICE=service_name] [ARGS=...]"
	@echo ""
	@echo "Main Commands:"
	@echo "  up              Start services"
	@echo "  down            Stop services"
	@echo "  build           Build services"
	@echo "  logs            View logs"
	@echo "  restart         Restart services"
	@echo "  shell           Open shell in container"
	@echo "  ps              List containers"
	@echo ""
	@echo "Development Commands:"
	@echo "  dev-up          Start development environment"
	@echo "  dev-down        Stop development environment"
	@echo "  dev-build       Build development containers"
	@echo "  dev-logs        View development logs"
	@echo "  quick-start     Build and start dev environment with health checks"
	@echo ""
	@echo "Production Commands:"
	@echo "  prod-up         Start production environment"
	@echo "  prod-down       Stop production environment"
	@echo "  prod-build      Build production containers"
	@echo "  quick-start-prod Build and start prod environment with health checks"
	@echo ""
	@echo "Health & Testing:"
	@echo "  health          Check gateway health"
	@echo "  health-backend  Check backend health"
	@echo "  health-all      Check all services"
	@echo "  test-all        Run all API tests"
	@echo "  test-security   Verify backend is not directly accessible"
	@echo ""
	@echo "Cleanup Commands:"
	@echo "  clean           Remove containers"
	@echo "  clean-all       Remove containers, images, and volumes"
	@echo "  clean-volumes   Prune unused volumes"
	@echo "  docker-clean    Clean Docker system"
	@echo "  docker-clean-all Clean all Docker resources"
	@echo ""
	@echo "Inspection Commands:"
	@echo "  stats           Show container resource usage"
	@echo "  inspect-backend Inspect backend container"
	@echo "  inspect-gateway Inspect gateway container"
	@echo "  network-inspect Inspect Docker network"
	@echo "  volume-inspect  List MongoDB volumes"
	@echo ""
	@echo "Database Commands:"
	@echo "  db-reset        Reset database"
	@echo "  mongo-shell     Open MongoDB shell"
	@echo ""
	@echo "Examples:"
	@echo "  make dev-up                  # Start development"
	@echo "  make prod-up                 # Start production"
	@echo "  make logs SERVICE=backend    # View backend logs"
	@echo "  make shell SERVICE=gateway   # Open gateway shell"

.PHONY: help up down build logs restart shell ps dev-up dev-down dev-build dev-logs \
        prod-up prod-down prod-build backend-build backend-install backend-type-check \
        backend-dev db-reset clean clean-all clean-volumes status health health-backend \
        health-all test-create-product test-get-products test-security test-all \
        docker-clean docker-clean-all quick-start quick-start-prod stats inspect-backend \
        inspect-gateway inspect-mongodb network-inspect volume-inspect backend-shell \
        gateway-shell mongo-shell

