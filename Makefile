################################################################################
# User configuration
################################################################################

# The handle of the Unison Share user who has published the code
SHARE_USER := unison

# The name of the project on Unison Share
SHARE_PROJECT := httpserver

PROJECT_RELEASE := 3.0.2

# The name of the main function to run within the application. This will
# generally have the type `'{Exception, IO} ()`.
MAIN_FUNCTION := example.main

# Set this if you use a custom Docker repository.
# NOTE: If you set this it should end with a trailing slash.
# Example: DOCKER_REPO := 'ghcr.io/ceedubs/'
DOCKER_REPO :=

################################################################################
# End user configuration
################################################################################


DOCKER_IMAGES := base download-ucm compile-unison-application unison-application
DOCKER_BUILD_TARGETS := $(addprefix docker-build-,$(DOCKER_IMAGES))
DOCKER_PUSH_TARGETS := $(addprefix docker-push-,application)

TAG := $(PROJECT_RELEASE)

.PHONY: build clean print-tag push docker-build-% docker-push-%

docker-build-%: TARGET=$(@:docker-build-%=%)
docker-build-%:
	DOCKER_BUILDKIT=1 docker build \
				 --target $(TARGET) \
				 --build-arg TAG=$(TAG) \
				 --build-arg DOCKER_REPO=$(DOCKER_REPO) \
				 --build-arg SHARE_USER=$(SHARE_USER) \
				 --build-arg SHARE_PROJECT=$(SHARE_PROJECT) \
				 --build-arg PROJECT_RELEASE=$(PROJECT_RELEASE) \
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
