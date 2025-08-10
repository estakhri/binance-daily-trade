# Binance Daily Trade Bot - Makefile
# ===================================

# Variables
DOCKER_IMAGE_NAME = binance-daily-trade
CONTAINER_NAME = my-btc-dca-bot
PYTHON = python3
PIP = pip3

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install test run clean docker-build docker-run docker-stop docker-logs docker-clean setup-env lint format check-env

# Default target
help: ## Show this help message
	@echo "$(GREEN)Binance Daily Trade Bot - Available Commands$(NC)"
	@echo "=============================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Development Setup
install: ## Install Python dependencies
	@echo "$(GREEN)Installing Python dependencies...$(NC)"
	$(PIP) install -r requirements.txt

install-dev: ## Install development dependencies
	@echo "$(GREEN)Installing development dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	$(PIP) install black flake8 pytest python-dotenv

setup-env: ## Create .env file template
	@echo "$(GREEN)Creating .env template...$(NC)"
	@if [ ! -f .env ]; then \
		echo "# Binance API Configuration" > .env; \
		echo "BINANCE_API_KEY=your_binance_api_key_here" >> .env; \
		echo "BINANCE_API_SECRET=your_binance_api_secret_here" >> .env; \
		echo "TRADE_AMOUNT=10" >> .env; \
		echo "" >> .env; \
		echo "# Telegram Configuration" >> .env; \
		echo "TELEGRAM_BOT_TOKEN=your_telegram_bot_token_here" >> .env; \
		echo "TELEGRAM_CHAT_ID=your_telegram_chat_id_here" >> .env; \
		echo "$(YELLOW).env file created! Please edit it with your actual credentials.$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists.$(NC)"; \
	fi

check-env: ## Check if .env file exists and has required variables
	@echo "$(GREEN)Checking .env configuration...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(RED)Error: .env file not found! Run 'make setup-env' first.$(NC)"; \
		exit 1; \
	fi
	@grep -q "BINANCE_API_KEY=" .env || (echo "$(RED)Error: BINANCE_API_KEY not found in .env$(NC)" && exit 1)
	@grep -q "BINANCE_API_SECRET=" .env || (echo "$(RED)Error: BINANCE_API_SECRET not found in .env$(NC)" && exit 1)
	@grep -q "TELEGRAM_BOT_TOKEN=" .env || (echo "$(RED)Error: TELEGRAM_BOT_TOKEN not found in .env$(NC)" && exit 1)
	@echo "$(GREEN).env file looks good!$(NC)"

# Running the Bot
run: check-env ## Run the bot locally
	@echo "$(GREEN)Running the bot...$(NC)"
	$(PYTHON) bot.py

test-run: check-env ## Test run the bot (same as run)
	@echo "$(GREEN)Test running the bot...$(NC)"
	$(PYTHON) bot.py

# Code Quality
lint: ## Run linting with flake8
	@echo "$(GREEN)Running linting...$(NC)"
	flake8 --max-line-length=88 --ignore=E203,W503 *.py

format: ## Format code with black
	@echo "$(GREEN)Formatting code...$(NC)"
	black --line-length=88 *.py

format-check: ## Check if code is formatted correctly
	@echo "$(GREEN)Checking code formatting...$(NC)"
	black --check --line-length=88 *.py

# Testing
test: ## Run tests (if any exist)
	@echo "$(GREEN)Running tests...$(NC)"
	@if [ -d "tests" ]; then \
		$(PYTHON) -m pytest tests/; \
	else \
		echo "$(YELLOW)No tests directory found. Consider adding tests!$(NC)"; \
	fi

# Docker Commands
docker-build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(DOCKER_IMAGE_NAME) .

docker-run: docker-build ## Build and run Docker container
	@echo "$(GREEN)Running Docker container...$(NC)"
	@if [ ! -f .env ]; then \
		echo "$(RED)Error: .env file not found! Run 'make setup-env' first.$(NC)"; \
		exit 1; \
	fi
	docker run -d \
		--name $(CONTAINER_NAME) \
		--env-file .env \
		--restart=unless-stopped \
		$(DOCKER_IMAGE_NAME)
	@echo "$(GREEN)Container started! Use 'make docker-logs' to view logs.$(NC)"

docker-stop: ## Stop Docker container
	@echo "$(GREEN)Stopping Docker container...$(NC)"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

docker-logs: ## View Docker container logs
	@echo "$(GREEN)Viewing container logs...$(NC)"
	docker logs -f $(CONTAINER_NAME)

docker-exec: ## Execute bash in running container
	@echo "$(GREEN)Executing bash in container...$(NC)"
	docker exec -it $(CONTAINER_NAME) /bin/bash

docker-test: ## Test run bot inside container
	@echo "$(GREEN)Test running bot inside container...$(NC)"
	docker exec -it $(CONTAINER_NAME) python3 /app/bot.py

docker-restart: docker-stop docker-run ## Restart Docker container

docker-clean: docker-stop ## Clean up Docker images and containers
	@echo "$(GREEN)Cleaning up Docker resources...$(NC)"
	-docker rmi $(DOCKER_IMAGE_NAME)
	-docker system prune -f

# Utility Commands
clean: ## Clean up Python cache files
	@echo "$(GREEN)Cleaning up cache files...$(NC)"
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +

logs: ## View cron logs (if running locally with cron)
	@echo "$(GREEN)Viewing cron logs...$(NC)"
	@if [ -f /var/log/cron.log ]; then \
		tail -f /var/log/cron.log; \
	else \
		echo "$(YELLOW)No cron logs found. This command works inside Docker container.$(NC)"; \
	fi

status: ## Check if Docker container is running
	@echo "$(GREEN)Checking container status...$(NC)"
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)✅ Container $(CONTAINER_NAME) is running$(NC)"; \
		docker ps | grep $(CONTAINER_NAME); \
	else \
		echo "$(YELLOW)⚠️  Container $(CONTAINER_NAME) is not running$(NC)"; \
	fi

# Development workflow
dev-setup: install-dev setup-env ## Complete development setup
	@echo "$(GREEN)Development environment setup complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "1. Edit .env file with your credentials"
	@echo "2. Run 'make test-run' to test the bot"
	@echo "3. Run 'make docker-run' to start the containerized bot"

# Production deployment
deploy: check-env docker-build docker-stop docker-run ## Deploy the bot (stop, build, run)
	@echo "$(GREEN)Deployment complete!$(NC)"
	@echo "$(YELLOW)Use 'make docker-logs' to monitor the bot.$(NC)"

# Quick commands
quick-test: install run ## Quick install and test
quick-deploy: deploy docker-logs ## Quick deploy and show logs
