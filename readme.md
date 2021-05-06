# Camel K Kafka Examples
 
This example demonstrates how to get started with `Camel K` and `Apache Kafka`. We will show how to quickly set up a Kafka Topic via Red Hat OpenShift Streams for Apache Kafka and be able to use it in a simple Producer/Consumer pattern `Integration`. We also will show how to simplify the credentials management via `Service Binding` when you want to access a Kafka instance in a `KameletBinding`.

The quickstart is based on the [Apache Camel K upstream Kafka example](https://github.com/apache/camel-k/tree/main/examples/kafka).

## Preparing the Kafka instance

The quickstart can run with any Kafka instance. However we want to focus how to connect a Red Hat OpenShift Streams for Apache Kafka to Camel K. In order to use it, you must login to the [Red Hat Cloud (Beta)](https://cloud.redhat.com/beta/). Please, consider the due [limitations](https://access.redhat.com/articles/5979061) of this offering at the time of writing this tutorial.

### Create an instance and a topic

In order to setup an instance and your first topic, you can follow up the [UI quickstart](https://cloud.redhat.com/beta/application-services/streams/resources?quickstart=getting-started) or use the [rhoas CLI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f520e427-cad2-40ce-823d-96234ccbc047).

> **Note:** we assume in this tutorial that you are creating a topic named `test`. You can use any other name, just make sure to reflect the name chosen in the `application.properties` configuration file.

### Prepare Kafka credentials

Once you've setup your first topic, you must create a set of credentials that you will be using during this quickstart:

* [Create a service account via UI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f351c4bd-9840-42ef-bcf2-b0c9be4ee30a#_7cb5e3f0-4b76-408d-b245-ff6959d3dbf7)
* [Create a service account via CLI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f520e427-cad2-40ce-823d-96234ccbc047#_5199d61c-8435-45b0-83f2-9c8c93ef3e31).

At this stage you should have the following credentials: a `kafka bootstrap URL`, a `service account id` and a `service account secret`.

## Preparing the cluster

This example can be run on any OpenShift 4.3+ cluster or a local development instance (such as [CRC](https://github.com/code-ready/crc)). Ensure that you have a cluster available and login to it using the OpenShift `oc` command line tool.

You need to create a new project named `camel-k-kafka` for running this example. This can be done directly from the OpenShift web console or by executing the command `oc new-project camel-k-kafka` on a terminal window.

You need to install the Camel K operator in the `camel-k-kafka` project. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"Red Hat Integration - Camel K"**. You will be given the option to install it globally on the cluster or on a specific namespace.
If using a specific namespace, make sure you select the `camel-k-kafka` project from the dropdown list.
This completes the installation of the Camel K operator (it may take a couple of minutes).

When the operator is installed, from the OpenShift Help menu ("?") at the top of the WebConsole, you can access the "Command Line Tools" page, where you can download the **"kamel"** CLI, that is required for running this example. The CLI must be installed in your system path.

Refer to the **"Red Hat Integration - Camel K"** documentation for a more detailed explanation of the installation steps for the operator and the CLI.

You can use the following section to check if your environment is configured properly.

### Optional Requirements

The following requirements are optional. They don't prevent the execution of the demo, but may make it easier to follow.

**VS Code Extension Pack for Apache Camel**

The VS Code Extension Pack for Apache Camel by Red Hat provides a collection of useful tools for Apache Camel K developers,
such as code completion and integrated lifecycle management. They are **recommended** for the tutorial, but they are **not**
required.

You can install it from the VS Code Extensions marketplace.

## 1. Preparing the project

We'll connect to the `camel-k-kafka` project and check the installation status.

To change project, open a terminal tab and type the following command:


```
oc project camel-k-kafka
```

We should now check that the operator is installed. To do so, execute the following command on a terminal:

Upon successful creation, you should ensure that the Camel K operator is installed:

```
oc get csv
```

When Camel K is installed, you should find an entry related to `red-hat-camel-k-operator` in phase `Succeeded`.

You can now proceed to the next section.

## 2. Secret preparation

You can take back the secret credentials provided earlier (`kafka bootstrap URL`,`service account id` and `service account secret`). Edit `application.properties` file filling those configuration. Now you can create a secret to contain the sensitive properties in the `application.properties` file that we will pass later to the running `Integration`s:

```
oc create secret generic kafka-props --from-file application.properties
```

## 3. Running a Kafka Producer integration

At this stage, run a producer integration. This one will fill the topic with a message, every second:

```
kamel run --secret kafka-props SaslSSLKafkaProducer.java --dev
```

The producer will create a new message and push into the topic and log some information.

```
...
[2] 2021-05-06 15:08:53,231 INFO  [FromTimer2Kafka] (Camel (camel-1) thread #7 - KafkaProducer[test]) Message correctly sent to the topic!
[2] 2021-05-06 15:08:54,155 INFO  [FromTimer2Kafka] (Camel (camel-1) thread #9 - KafkaProducer[test]) Message correctly sent to the topic!
...
```

> **Note:** Both `SaslSSLKafkaProducer.java` and `SaslSSLKafkaConsumer.java` files specify a runtime `kafka-clients` maven dependency needed in version `1.3.x` of Camel K. It may not be needed to specify it in future Camel K releases.

## 4. Running a Kafka Consumer integration

Now, open another shell and run the consumer integration using the command:

```
kamel run --secret kafka-props SaslSSLKafkaConsumer.java --dev
```

A consumer will start logging the events found in the Topic:

```
[1] 2021-05-06 15:09:47,466 INFO  [FromKafka2Log] (Camel (camel-1) thread #0 - KafkaConsumer[test]) Message #133
[1] 2021-05-06 15:09:48,280 INFO  [FromKafka2Log] (Camel (camel-1) thread #0 - KafkaConsumer[test]) Message #134
[1] 2021-05-06 15:09:49,264 INFO  [FromKafka2Log] (Camel (camel-1) thread #0 - KafkaConsumer[test]) Message #135

```

> **Note:** When you terminate a "dev mode" execution, also the remote integration will be deleted. This gives the experience of a local program execution, but the integration is actually running in the remote cluster. To keep the integration running and not linked to the terminal, you can run it without "dev mode" (`--dev` flag)

## 5. Uninstall

To cleanup everything, execute the following command:

```
oc delete project camel-k-kafka
```