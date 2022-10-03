MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(MAKEFILE_DIR)/standard_defs.mk

export OPENSSL_STATIC=1

CLEAN_DIRS := $(CLEAN_DIRS)

DOMAINS := $(shell find . -mindepth 2 -maxdepth 2 -name domain.yaml \
	-exec dirname {} \; | awk -F/ '{print $$NF}')

clean: clean_containers

distclean: clean_docker clean_markers

build: examples sdl

clean_containers:
	docker-compose -f docker/docker-compose.yaml rm -f || true

clean_docker:
	docker-compose -f docker/docker-compose.yaml down -v --rmi all || true

$(MARKERS):
	mkdir $(MARKERS)

define domain_tmpl =
.PHONY: examples
examples: example-$(1)

.PHONY: inmem-examples
inmem-examples: $(MARKERS)/example-inmem-$(1)

.PHONY: release-examples
release-examples: $(MARKERS)/example-release-$(1)

example-$(1): $(MARKERS)/example-inmem-$(1) $(MARKERS)/example-release-$(1)

$(MARKERS)/example-inmem-$(1): $(MARKERS)
	@echo "Building $(1) debug inmem example ..."
	docker-compose -f docker/docker-compose.yaml build \
		--build-arg RELEASE=no \
		--build-arg DOMAIN=$(1)
	docker tag chronicle-example:$(ISOLATION_ID) \
		chronicle-$(1)-inmem:$(ISOLATION_ID)
	@touch $(MARKERS)/$@

$(MARKERS)/example-release-$(1): $(MARKERS)
	@echo "Building $(1) release inmem example ..."
	docker-compose -f docker/docker-compose.yaml build \
		--build-arg RELEASE=yes \
		--build-arg DOMAIN=$(1)
	docker tag chronicle-example:$(ISOLATION_ID) \
		chronicle-$(1)-release:$(ISOLATION_ID)
	@touch $(MARKERS)/$@

$(1)/chronicle.graphql: $(MARKERS)/example-inmem-$(1)
	docker run --env RUST_LOG=debug chronicle-$(1)-inmem:$(ISOLATION_ID) \
		chronicle export-schema > $(1)/chronicle.graphql

clean-graphql-$(1):
	rm -f $(1)/chronicle.graphql

.PHONY: sdl
sdl: $(1)/chronicle.graphql

.PHONY: run-$(1)
run-$(1): $(MARKERS)/example-inmem-$(1)
	docker run --env RUST_LOG=debug --publish 9982:9982 -it --rm \
		chronicle-$(1)-inmem:$(ISOLATION_ID) bash -c \
		'chronicle --console-logging pretty serve-graphql --interface 0.0.0.0:9982 \
		--open'

.PHONY: clean-images-$(1)
clean-images-$(1): $(MARKERS)
	docker rmi chronicle-$(1)-inmem:$(ISOLATION_ID) || true
	docker rmi chronicle-$(1)-release:$(ISOLATION_ID) || true
	rm -f $(MARKERS)/*-$(1)

clean-$(1): clean-images-$(1) clean-graphql-$(1)

clean: clean-$(1)

endef

$(foreach domain,$(DOMAINS),$(eval $(call domain_tmpl,$(domain))))
