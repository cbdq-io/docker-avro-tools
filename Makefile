AVRO_TOOLS_VERSION = 1.12.0

all: clean lint build test trivy

KEYS:
	curl --output KEYS https://downloads.apache.org/avro/KEYS
	gpg --import KEYS

avro-tools-$(AVRO_TOOLS_VERSION).jar:
	curl --output avro-tools-$(AVRO_TOOLS_VERSION).jar https://repo1.maven.org/maven2/org/apache/avro/avro-tools/$(AVRO_TOOLS_VERSION)/avro-tools-$(AVRO_TOOLS_VERSION).jar

avro-tools-$(AVRO_TOOLS_VERSION).jar.asc:
	curl --output avro-tools-$(AVRO_TOOLS_VERSION).jar.asc https://repo1.maven.org/maven2/org/apache/avro/avro-tools/$(AVRO_TOOLS_VERSION)/avro-tools-$(AVRO_TOOLS_VERSION).jar.asc
	gpg --verify avro-tools-$(AVRO_TOOLS_VERSION).jar.asc avro-tools-$(AVRO_TOOLS_VERSION).jar

build: KEYS avro-tools-$(AVRO_TOOLS_VERSION).jar avro-tools-$(AVRO_TOOLS_VERSION).jar.asc
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose build avro-tools

changelog:
	GIT_TAG=$(AVRO_TOOLS_VERSION) gitchangelog > CHANGELOG.md

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
	@echo $(AVRO_TOOLS_VERSION)

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
