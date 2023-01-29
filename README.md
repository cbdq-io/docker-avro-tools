# docker-avro-tools

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
  ghcr.io/cbdq-io/docker-avro-tools:1.9.1 \
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
