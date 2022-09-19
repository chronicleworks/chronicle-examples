MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(MAKEFILE_DIR)/standard_defs.mk

export OPENSSL_STATIC=1

CLEAN_DIRS := $(CLEAN_DIRS)

DOMAIN ?= artworld

export EXAMPLE=${DOMAIN}

clean: clean_containers clean_target

distclean: clean_docker clean_markers

build: $(MARKERS)/build

analyze: analyze_fossa

publish: gh-create-draft-release
	container_id=$$(docker create example-chronicle:${ISOLATION_ID}); \
	  docker cp $$container_id:/usr/local/bin/example-chronicle `pwd`/target/ && \
		target/example-chronicle export-schema > `pwd`/target/chronicle.graphql 2>&1 && \
		docker rm $$container_id
	container_id=$$(docker create example-chronicle-inmem:${ISOLATION_ID}); \
	  docker cp $$container_id:/usr/local/bin/example-chronicle `pwd`/target/example-chronicle-inmem && \
		docker rm $$container_id
	if [ "$(RELEASABLE)" = "yes" ]; then \
	  $(GH_RELEASE) upload $(VERSION) target/* ; \
	fi

run:
	docker-compose -f docker/chronicle.yaml up --force-recreate

.PHONY: stop
stop:
	docker-compose -f docker/chronicle.yaml down || true

$(MARKERS)/build:
	@echo "Building ${EXAMPLE} example ..."
	cp ${EXAMPLE}/domain.yaml domain.yaml
	docker-compose -f docker/docker-compose.yaml build
	touch $@

clean_containers:
	docker-compose -f docker/chronicle.yaml rm -f || true
	docker-compose -f docker/docker-compose.yaml rm -f || true

clean_docker: stop
	docker-compose -f docker/chronicle.yaml down -v --rmi all || true
	docker-compose -f docker/docker-compose.yaml down -v --rmi all || true

markers:
	mkdir markers

markers/domain: domain.yaml markers
	@echo "Building ${EXAMPLE} example ..."
	cp ${EXAMPLE}/domain.yaml domain.yaml
	docker-compose -f docker/docker-compose.yaml build
	touch $@

.PHONY: run-standalone-chronicle
run-standalone-chronicle: markers/domain
	docker run --env RUST_LOG=debug --publish 9982:9982 -it ${EXAMPLE}-chronicle-inmem:local bash -c 'chronicle --console-logging pretty serve-graphql --interface 0.0.0.0:9982 --open'

chronicle.graphql: markers/domain
	docker run --env RUST_LOG=debug ${EXAMPLE}-chronicle-inmem:local chronicle export-schema > chronicle.graphql

.PHONY: sdl
sdl: crates/consent-api/graphql/schema/chronicle.graphql

clean_target:
	rm -rf target
