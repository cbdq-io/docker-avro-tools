AVRO_TOOLS_VERSION = 1.12.0
INCREMENT = 20240112

all: clean lint build test trivy

avro-version:
	@echo $(AVRO_TOOLS_VERSION)

build:
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose build avro-tools

changelog:
	GIT_TAG=$(AVRO_TOOLS_VERSION)-$(INCREMENT) gitchangelog > CHANGELOG.md

clean:
	docker rm -f avro-tools

cleanall: clean
	docker compose down -t 0
	docker compose -f tests/compose/grype.yml down -t 0
	rm -f KEYS avro-tools-$(AVRO_TOOLS_VERSION).jar avro-tools-$(AVRO_TOOLS_VERSION).jar.asc
	docker system prune --force --volumes
	docker volume prune --all --force

lint:
	yamllint -s .
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose config --quiet
	docker run --rm -i hadolint/hadolint < Dockerfile
	flake8

tag:
	@echo $(AVRO_TOOLS_VERSION)-$(INCREMENT)

test:
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose run \
	  --detach \
	  --entrypoint 'sleep infinity' \
	  --name avro-tools \
	  --rm \
	  avro-tools
	pytest

trivy:
	trivy image --severity HIGH,CRITICAL --ignore-unfixed avro-tools:latest

update-trivy-ignore:
	trivy image --format json --ignore-unfixed --severity HIGH,CRITICAL avro-tools:latest | jq -r '.Results[1].Vulnerabilities[].VulnerabilityID' | sort -u | tee .trivyignore
