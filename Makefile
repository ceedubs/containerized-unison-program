################################################################################
# User configuration
################################################################################

# The handle of the Unison Share user who has published the code
SHARE_USER := ceedubs

# The namespace of the code, relative to the Unison Share user
SHARE_NAMESPACE := public.hello_server.latest

# The name of the main function to run within the application. This will
# generally have the type `'{Exception, IO} ()`.
MAIN_FUNCTION := main

# Set this if you use a custom Docker repository.
# NOTE: If you set this it should end with a trailing slash.
# Example: DOCKER_REPO := 'ghcr.io/ceedubs/'
DOCKER_REPO :=

################################################################################
# End user configuration
################################################################################


DOCKER_IMAGES := base download-ucm fetch-unison-application-hash compile-unison-application unison-application
DOCKER_BUILD_TARGETS := $(addprefix docker-build-,$(DOCKER_IMAGES))
DOCKER_PUSH_TARGETS := $(addprefix docker-push-,application)

# The tag for the Docker images. This is used for cache invalidation, so it's important that it is
# unique per build.
TAG := $(shell date -u +'%F_%H-%M-%S')

.PHONY: build clean print-tag push docker-build-% docker-push-%

docker-build-%: TARGET=$(@:docker-build-%=%)
docker-build-%:
	DOCKER_BUILDKIT=1 docker build \
				 --target $(TARGET) \
				 --build-arg TAG=$(TAG) \
				 --build-arg DOCKER_REPO=$(DOCKER_REPO) \
				 --build-arg SHARE_USER=$(SHARE_USER) \
				 --build-arg SHARE_NAMESPACE=$(SHARE_NAMESPACE) \
				 --build-arg MAIN_FUNCTION=$(MAIN_FUNCTION) \
				 --tag $(DOCKER_REPO)$(TARGET):$(TAG) \
				 --tag $(DOCKER_REPO)$(TARGET):latest \
					docker

docker-push-%: TARGET=$(@:docker-push-%=%)
docker-push-%:
	docker push --all-tags $(DOCKER_REPO)$(TARGET)

build: $(DOCKER_BUILD_TARGETS)
	@echo "Built images with tags 'latest' and '$(TAG)'"

push: $(DOCKER_PUSH_TARGETS)
	@echo "Pushed images with tags 'latest' and '$(TAG)'"

print-tag:
	@echo $(TAG)
