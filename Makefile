# Makefile

# Configuration
SSH_PORT ?= 2222
JUPYTER_PORT ?= 8889
SHM_SIZE ?= 16g
IMAGE_NAME ?= my-ai-env
tag?= latest
CONTAINER_NAME ?= my-ai-container
VOLUME_PATH ?= /tmp/docker-container-tmp-volume
WORKDIR ?= /workspace
GPUS?=all
TAILSCALE_AUTHKEY?="tskey-auth-xxxxxx-xxxxxxx"
SMTP_PASSWORD?="xxxxx"
EMAIL_ADDRESS?="user@mail.com"

.PHONY: build run stop remove

# Build Docker image
build:
	docker build . -t $(IMAGE_NAME)

# Run Docker container
run:
	sudo mkdir -p $(VOLUME_PATH)
	make build
	docker run -itd \
		--name $(CONTAINER_NAME) \
		--gpus $(GPUS) \
		-p $(SSH_PORT):22 \
		-p $(JUPYTER_PORT):8889 \
		--shm-size=$(SHM_SIZE) \
		-v $(VOLUME_PATH):$(WORKDIR) \
		-e EMAIL_ADDRESS=$(EMAIL_ADDRESS) \
		-e SMTP_PASSWORD=$(SMTP_PASSWORD) \
  		-e TAILSCALE_AUTHKEY=$(TAILSCALE_AUTHKEY) \
		$(IMAGE_NAME):$(tag)

# Stop and remove container
stop:
	docker stop $(CONTAINER_NAME)

remove:
	docker rm $(CONTAINER_NAME)

enter-container:
	@echo "Entering container..."
	docker exec -it $(CONTAINER_NAME) /bin/bash
