FROM amazoncorretto:11

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

COPY --chown=avro-tools:avro-tools \
  avro-tools-${AVRO_TOOLS_VERSION}.jar \
  /usr/local/avro-tools/avro-tools-${AVRO_TOOLS_VERSION}.jar
WORKDIR /usr/local/avro-tools
USER avro-tools
ENTRYPOINT [ "java", "-jar", "/usr/local/avro-tools/avro-tools-1.12.0.jar" ]
