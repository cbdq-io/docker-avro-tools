FROM amazoncorretto:8

RUN yum clean all \
  && rm -rf /var/cache/yum \
  && yum install -y shadow-utils \
  && useradd \
    --comment 'Avro Tools User' \
    --home-dir /usr/local/avro-tools \
    --create-home \
    --uid 1000 \
    --user-group \
    avro-tools

COPY --chown=avro-tools:avro-tools avro-tools-1.9.1.jar /usr/local/avro-tools/avro-tools-1.9.1.jar
WORKDIR /usr/local/avro-tools
USER avro-tools
ENTRYPOINT [ "java", "-jar", "/usr/local/avro-tools/avro-tools-1.9.1.jar" ]
