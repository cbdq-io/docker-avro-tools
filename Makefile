AVRO_TOOLS_VERSION = 1.9.1

all: lint build test

KEYS:
	curl --output KEYS https://downloads.apache.org/avro/KEYS

avro-tools-$(AVRO_TOOLS_VERSION).jar:
	curl --output avro-tools-$(AVRO_TOOLS_VERSION).jar https://repo1.maven.org/maven2/org/apache/avro/avro-tools/$(AVRO_TOOLS_VERSION)/avro-tools-$(AVRO_TOOLS_VERSION).jar

avro-tools-$(AVRO_TOOLS_VERSION).jar.asc:
	curl --output avro-tools-$(AVRO_TOOLS_VERSION).jar.asc https://repo1.maven.org/maven2/org/apache/avro/avro-tools/$(AVRO_TOOLS_VERSION)/avro-tools-$(AVRO_TOOLS_VERSION).jar.asc

clean:
	rm -f KEYS avro-tools-$(AVRO_TOOLS_VERSION).jar avro-tools-$(AVRO_TOOLS_VERSION).jar.asc

lint: KEYS avro-tools-$(AVRO_TOOLS_VERSION).jar avro-tools-$(AVRO_TOOLS_VERSION).jar.asc
	yamllint -s .
	docker compose config --quiet
	docker run --rm -i hadolint/hadolint < Dockerfile
	gpg --import KEYS
	gpg --verify avro-tools-$(AVRO_TOOLS_VERSION).jar.asc avro-tools-$(AVRO_TOOLS_VERSION).jar
