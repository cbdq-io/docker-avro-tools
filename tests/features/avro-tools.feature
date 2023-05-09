Feature: Avro Tools Container Tests

  Scenario: Check Java is Installed in the Path
    Given the host with URL "docker://avro-tools" is ready within 10 seconds
    Then the command "java" exists in path

  Scenario: Check Java 8 is Installed
    Given the host with URL "docker://avro-tools" is ready
    When the command is "java -version"
    And the package is java-1.8.0-amazon-corretto-devel
    Then the command stderr contains "Corretto-8"
    And the command stderr contains the regex "openjdk version \"1.8\\W[0-9]"
    And the command stdout is empty
    And the command return code is 0
    And the package is installed

  Scenario: Check the Avro Tools User
    Given the host with URL "docker://avro-tools" is ready
    When the user is "avro-tools"
    Then the user state is present
    And the user group is avro-tools
    And the user uid is 1000

  Scenario: Check Directory Resource
    Given the host with URL "docker://avro-tools" is ready
    When the file is /usr/local/avro-tools
    Then the file is present
    And the file type is directory
    And the file owner is avro-tools
    And the file group is avro-tools

  Scenario: Check the JAR Executes as Expected
    Given the host with URL "docker://avro-tools" is ready
    When the command is "java -jar /usr/local/avro-tools/avro-tools-1.11.1.jar"
    Then the command return code is 1
    And the command stderr contains "Version 1.11.1"
    And the command stderr contains "Available tools:"

  Scenario: Check JAR Built With Java 8
    Given the host with URL "docker://root@avro-tools" is ready
    When the command is "jar xf avro-tools-1.11.1.jar"
    And the command is "yum install -y file"
    And the command is "file org/apache/avro/Schema.class"
    Then the command stdout contains "(Java 1.8)"
