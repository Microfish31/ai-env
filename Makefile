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
CUDA_VERSION?="11.8.0"
PYTHON_VERSION?="3.12"
ENABLE_SSH?=false

# Optional variables
SSH_PASSWORD?="root"
TAILSCALE_AUTHKEY?=""
SMTP_PASSWORD?=""
EMAIL_ADDRESS?=""

.PHONY: build run stop remove

# Build Docker image
build:
	docker build . -t $(IMAGE_NAME) \
	--build-arg CUDA_VERSION=$(CUDA_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SSH_PSW=$(SSH_PASSWORD) \

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
		-e HOSTNAME=$(CONTAINER_NAME) \
		-e ENABLE_SSH=$(ENABLE_SSH) \
		--restart=always \
		$(IMAGE_NAME):$(tag)

# Stop and remove container
stop:
	docker stop $(CONTAINER_NAME)

remove:
	docker rm $(CONTAINER_NAME)

enter-container:
	@echo "Entering container..."
	docker exec -it $(CONTAINER_NAME) /bin/bash
