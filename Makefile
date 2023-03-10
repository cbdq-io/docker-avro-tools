AVRO_TOOLS_VERSION = 1.9.1

all: clean lint build test

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

clean:
	docker rm -f avro-tools

cleanall: clean
	rm -f KEYS avro-tools-$(AVRO_TOOLS_VERSION).jar avro-tools-$(AVRO_TOOLS_VERSION).jar.asc
	docker system prune --force --volumes

lint:
	yamllint -s .
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose config --quiet
	docker run --rm -i hadolint/hadolint < Dockerfile
	flake8

test:
	AVRO_TOOLS_VERSION=$(AVRO_TOOLS_VERSION) docker compose run \
	  --detach \
	  --entrypoint 'sleep infinity' \
	  --name avro-tools \
	  --rm \
	  avro-tools
	pytest
