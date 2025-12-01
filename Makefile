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

health:
	curl http://localhost:5921/health

# Help:
help:
	@echo "Usage: make [command] [MODE=dev|prod] [SERVICE=service_name] [ARGS=...]"
	@echo ""
	@echo "Commands:"
	@echo "  up              Start services"
	@echo "  down            Stop services"
	@echo "  build           Build services"
	@echo "  logs            View logs"
	@echo "  restart         Restart services"
	@echo "  shell           Open shell in container"
	@echo "  ps              List containers"
	@echo "  clean           Remove containers"
	@echo "  clean-all       Remove containers, images, and volumes"
