Feature: Kafka producer/consumer

  Background:
    Given Camel K resource polling configuration
      | maxAttempts          | 200   |
      | delayBetweenAttempts | 2000  |
    Given variable user is ""
    Given variable password is ""
    Given variables
      | bootstrap.server.host | my-cluster-kafka-bootstrap |
      | bootstrap.server.port | 9092 |
      | securityProtocol      | PLAINTEXT |
      | saslMechanism         | PLAIN |
      | topic                 | my-topic |

  Scenario: Create Kafka producer
    Given Camel K integration property file application.properties
    When load Camel K integration SaslSSLKafkaProducer.java with configuration
      | name | kafka-producer |
    Then Camel K integration kafka-producer should be running

  Scenario: Create Kafka consumer
    Given Camel K integration property file application.properties
    When load Camel K integration SaslSSLKafkaConsumer.java with configuration
      | name | kafka-consumer |
    Then Camel K integration kafka-consumer should be running
    Then Camel K integration kafka-consumer should print Message #5

  Scenario: Remove resources
    Given delete Camel K integration kafka-producer
    Given delete Camel K integration kafka-consumer
