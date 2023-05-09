# docker-avro-tools

[![CI](https://github.com/cbdq-io/docker-avro-tools/actions/workflows/ci.yml/badge.svg)](https://github.com/cbdq-io/docker-avro-tools/actions/workflows/ci.yml)

Make [avro-tools](https://avro.apache.org/docs/1.11.1/getting-started-java/)
available via a Docker container.

## Example

Say we have a file called `tests/resources/AccountService.avdl` that contains
the following IDL code:

```
@namespace("org.sample")
protocol AccountService {

    record Account {
    long id;
    string name;
    union {null, string} description = null;
    }

    Account addAccount(string name, union {null, string} description);
}
```

Then running the following command:

```shell
docker run \
  --rm \
  --volume "$( pwd )/tests/resources:/mnt/idl" \
  --volume /tmp:/mnt/schemas \
  ghcr.io/cbdq-io/avro-tools:1.11.1 \
  idl2schemata /mnt/idl/AccountService.avdl /mnt/schemas
```

will create a file called `/tmp/Account.avsc` with the following contents:

```json
{
  "type" : "record",
  "name" : "Account",
  "namespace" : "org.sample",
  "fields" : [ {
    "name" : "id",
    "type" : "long"
  }, {
    "name" : "name",
    "type" : "string"
  }, {
    "name" : "description",
    "type" : [ "null", "string" ],
    "default" : null
  } ]
}
```

## Manually Deploying a Built Image

First authenticate against the GitHub Container Registry:

```shell
echo $GITHUB_TOKEN | docker login ghcr.io -u GITHUB_USERNAME --password-stdin
```

Then prepare the Docker images to be deployed by running:

```shell
make
```

This will create the following images:

1. `ghcr.io/cbdq-io/avro-tools:1.11.1`
1. `ghcr.io/cbdq-io/avro-tools:latest`
1. `ghcr.io/cbdq-io/avro-tools:stable`

Push whichever of these images that you want to the registry, for example
this command pushes the first two from the list above:

```shell
docker push ghcr.io/cbdq-io/avro-tools:1.11.1

```
