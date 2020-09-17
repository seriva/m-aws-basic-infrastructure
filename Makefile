VERSION ?= 0.0.1
USER := epiphany
IMAGE := awsbi

#used for correctly setting shared folder permissions
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

.PHONY: build release metadata

warning:
	$(error Please specify make target: make (build/release/metadata) )

build: file-guard-Dockerfile guard-VERSION guard-IMAGE guard-USER
	docker build --rm \
		--build-arg ARG_M_VERSION=$(VERSION) \
		--build-arg ARG_HOST_UID=$(HOST_UID) \
		--build-arg ARG_HOST_GID=$(HOST_GID) \
		-t $(USER)/$(IMAGE):$(VERSION) \
		.

release: guard-VERSION guard-IMAGE guard-USER
	docker build \
		--build-arg ARG_M_VERSION=$(VERSION) \
		-t $(USER)/$(IMAGE):$(VERSION) \
		.

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

file-guard-%:
	@if [ ! -f $* ]; then \
	 	echo "File '$*' not exists"; \
		exit 1; \
	fi

metadata: guard-VERSION guard-IMAGE guard-USER
	docker run --rm \
		-t $(USER)/$(IMAGE):$(VERSION) \
		metadata
