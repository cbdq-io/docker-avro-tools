Feature: Avro Tools Container Tests

  Scenario: Check Java is Installed in the Path
    Given the TestInfra host with URL "docker://avro-tools" is ready within 10 seconds
    Then the TestInfra command "java" exists in path

  Scenario: Check Java 11 is Installed
    Given the TestInfra host with URL "docker://avro-tools" is ready
    When the TestInfra command is "java -version"
    And the TestInfra package is java-11-amazon-corretto-devel
    Then the TestInfra command stderr contains "Corretto-11"
    And the TestInfra command stderr contains the regex "openjdk version \"11\.[0-9]"
    And the TestInfra command stdout is empty
    And the TestInfra command return code is 0
    And the TestInfra package is installed

  Scenario: Check the Avro Tools User
    Given the TestInfra host with URL "docker://avro-tools" is ready
    When the TestInfra user is "avro-tools"
    Then the TestInfra user state is present
    And the TestInfra user group is avro-tools
    And the TestInfra user uid is 1000

  Scenario: Check Directory Resource
    Given the TestInfra host with URL "docker://avro-tools" is ready
    When the TestInfra file is /usr/local/avro-tools
    Then the TestInfra file is present
    And the TestInfra file type is directory
    And the TestInfra file owner is avro-tools
    And the TestInfra file group is avro-tools

  Scenario: Check the JAR Executes as Expected
    Given the TestInfra host with URL "docker://avro-tools" is ready
    When the TestInfra command is "java -jar /usr/local/avro-tools/avro-tools-1.12.0.jar"
    Then the TestInfra command return code is 1
    And the TestInfra command stderr contains "Version 1.12.0"
    And the TestInfra command stderr contains "Available tools:"

  Scenario: Check JAR Built With Java 11
    Given the TestInfra host with URL "docker://root@avro-tools" is ready
    When the TestInfra command is "jar xf avro-tools-1.12.0.jar"
    And the TestInfra command is "yum install -y file"
    And the TestInfra command is "file org/apache/avro/Schema.class"
    Then the TestInfra command stdout contains "version 55.0"

  Scenario: Check We Have the Latest Version
    Given the TestInfra host with URL "docker://avro-tools" is ready
    When the TestInfra command is "curl --fail --silent https://dlcdn.apache.org/avro/avro-1.12.0"
    Then the TestInfra command return code is 0
