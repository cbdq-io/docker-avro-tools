FROM debian:12 AS download

ARG AVRO_TOOLS_VERSION

WORKDIR /tmp

# hadolint ignore=DL3008
RUN apt-get clean \
  && apt-get update \
  && apt-get install --no-install-recommends --yes ca-certificates gpg gpg-agent wget \
  && wget -qO KEYS https://downloads.apache.org/avro/KEYS \
  && gpg --import KEYS \
  && wget -qO avro-tools-${AVRO_TOOLS_VERSION}.jar https://repo1.maven.org/maven2/org/apache/avro/avro-tools/${AVRO_TOOLS_VERSION}/avro-tools-${AVRO_TOOLS_VERSION}.jar \
  && wget -qO avro-tools-${AVRO_TOOLS_VERSION}.jar.asc https://repo1.maven.org/maven2/org/apache/avro/avro-tools/${AVRO_TOOLS_VERSION}/avro-tools-${AVRO_TOOLS_VERSION}.jar.asc \
  && gpg --verify avro-tools-${AVRO_TOOLS_VERSION}.jar.asc avro-tools-${AVRO_TOOLS_VERSION}.jar

FROM amazoncorretto:17

ARG AVRO_TOOLS_VERSION

RUN yum clean all \
  && rm -rf /var/cache/yum \
  && yum upgrade -y java-11-amazon-corretto-devel openldap \
  && yum install -y shadow-utils \
  && useradd \
    --comment 'Avro Tools User' \
    --home-dir /usr/local/avro-tools \
    --create-home \
    --uid 1000 \
    --user-group \
    avro-tools

COPY --from=download --chown=avro-tools:avro-tools \
  /tmp/avro-tools-${AVRO_TOOLS_VERSION}.jar \
  /usr/local/avro-tools/avro-tools-${AVRO_TOOLS_VERSION}.jar
WORKDIR /usr/local/avro-tools
USER avro-tools
ENTRYPOINT [ "java", "-jar", "/usr/local/avro-tools/avro-tools-1.12.0.jar" ]
