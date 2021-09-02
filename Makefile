NAME = apicast
NAMESPACE = quay.io/harsha544
VERSION ?= tinyproxy
DOCKER ?= $(shell which docker 2> /dev/null || which podman 2> /dev/null || echo docker)

ifeq ($(shell uname --hardware-platform), x86_64)

	ARCH = amd64
else

	ARCH ?= $(shell arch)
endif

LOCAL_IMAGE := $(NAME):$(VERSION)-$(ARCH)
REMOTE_IMAGE := $(NAMESPACE)/$(LOCAL_IMAGE)


MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THISDIR_PATH := $(patsubst %/,%,$(abspath $(dir $(MKFILE_PATH))))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

all: docker-build docker-tag

update: docker-build docker-push

docker-build: ## Build container image with name LOCAL_IMAGE (NAME:VERSION).
	$(DOCKER) build -f $(THISDIR_PATH)/Dockerfile -t $(LOCAL_IMAGE) $(PROJECT_PATH)

docker-tag: docker-build ## Tag IMAGE_NAME in the container registry
	$(DOCKER) tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)

docker-push: docker-tag ## Push to the container registry
	$(DOCKER) push $(REMOTE_IMAGE)

docker-pull: ## Pull the container from the Registry
	$(DOCKER) pull $(REMOTE_IMAGE)

manifest-create:  ## Create the Manifest
	$(DOCKER) manifest create $(NAMESPACE)/$(NAME):$(VERSION) --amend $(NAMESPACE)/$(NAME):$(VERSION)-ppc64le --amend $(NAMESPACE)/$(NAME):$(VERSION)-amd64

manifest-push: create-manifest ## Publish the Manifest
	$(DOCKER) manifest create $(NAMESPACE) 

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@echo -e "Set the DOCKER variable to your docker-compatible program (Docker and Podman supported)\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
