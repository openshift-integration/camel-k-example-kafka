# Camel K Kafka Basic Quickstart

This example demonstrates how to get started with `Camel K` and `Apache Kafka`. We will show how to quickly set up a Kafka Topic via Red Hat OpenShift Streams for Apache Kafka and be able to use it in a simple Producer/Consumer pattern `Integration`.

The quickstart is based on the [Apache Camel K upstream Kafka example](https://github.com/apache/camel-k/tree/main/examples/kafka).

## Before you begin

Make sure you check-out this repository from git and open it with [VSCode](https://code.visualstudio.com/).

Instructions are based on [VSCode Didact](https://github.com/redhat-developer/vscode-didact), so make sure it's installed
from the VSCode extensions marketplace.

From the VSCode UI, right-click on the `readme.didact.md` file and select "Didact: Start Didact tutorial from File". A new Didact tab will be opened in VS Code.

Make sure you've opened this readme file with Didact before jumping to the next section.

## Preparing the Kafka instance

The quickstart can run with any Kafka instance. However we want to focus how to connect a Red Hat OpenShift Streams for Apache Kafka to Camel K. In order to use it, you must login to the [Red Hat Cloud (Beta)](https://cloud.redhat.com/beta/). Please, consider the due [limitations](https://access.redhat.com/articles/5979061) of this offering at the time of writing this tutorial.

### Create an instance and a topic

In order to setup an instance and your first topic, you can follow up the [UI quickstart](https://cloud.redhat.com/beta/application-services/streams/resources?quickstart=getting-started) or use the [rhoas CLI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f520e427-cad2-40ce-823d-96234ccbc047).

> **Note:** we assume in this tutorial that you are creating a topic named `test`. You can use any other name, just make sure to reflect the name chosen in the `application.properties` configuration file.

### Prepare Kafka credentials

Once you've setup your first topic, you must create a set of credentials that you will be using during this quickstart:

* [Create a service account via UI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f351c4bd-9840-42ef-bcf2-b0c9be4ee30a#_7cb5e3f0-4b76-408d-b245-ff6959d3dbf7)
* [Create a service account via CLI](https://access.redhat.com/documentation/en-us/red_hat_openshift_streams_for_apache_kafka/1/guide/f520e427-cad2-40ce-823d-96234ccbc047#_5199d61c-8435-45b0-83f2-9c8c93ef3e31).

At this stage you should have the following credentials: a `kafka bootstrap URL`, a `service account id` and a `service account secret`. You may also want to take note of the `Token endpoint URL` if you choose to use "SASL/OAUTHBEARER" instead of "SASL/Plain" authentication method.

## Preparing the cluster

This example can be run on any OpenShift 4.3+ cluster or a local development instance (such as [CRC](https://github.com/code-ready/crc)). Ensure that you have a cluster available and login to it using the OpenShift `oc` command line tool.

You need to create a new project named `camel-k-kafka` for running this example. This can be done directly from the OpenShift web console or by executing the command `oc new-project camel-k-kafka` on a terminal window.

```
oc new-project camel-k-kafka
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20new-project%20camel-k-kafka&completion=Project%20changed. "Switched to the project that will run Camel K Kafka example"){.didact})

You need to install the Camel K operator in the `camel-k-kafka` project. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"Red Hat Integration - Camel K"**. You will be given the option to install it globally on the cluster or on a specific namespace.
If using a specific namespace, make sure you select the `camel-k-kafka` project from the dropdown list.
This completes the installation of the Camel K operator (it may take a couple of minutes).

Upon successful creation, you should ensure that the Camel K operator is installed:

```
oc get csv
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20csv&completion=Checking%20Cluster%20Service%20Versions. "Opens a new terminal and sends the command above"){.didact})

When Camel K is installed, you should find an entry related to `red-hat-camel-k-operator` in phase `Succeeded`.

When the operator is installed, from the OpenShift Help menu ("?") at the top of the WebConsole, you can access the "Command Line Tools" page, where you can download the **"kamel"** CLI, that is required for running this example. The CLI must be installed in your system path.

Refer to the **"Red Hat Integration - Camel K"** documentation for a more detailed explanation of the installation steps for the operator and the CLI.

You can use the following section to check if your environment is configured properly.

## Requirements

<a href='didact://?commandId=vscode.didact.validateAllRequirements' title='Validate all requirements!'><button>Validate all Requirements at Once!</button></a>

**OpenShift CLI ("oc")**

The OpenShift CLI tool ("oc") will be used to interact with the OpenShift cluster.

[Check if the OpenShift CLI ("oc") is installed](didact://?commandId=vscode.didact.cliCommandSuccessful&text=oc-requirements-status$$oc%20help&completion=Checked%20oc%20tool%20availability "Tests to see if `oc help` returns a 0 return code"){.didact}

*Status: unknown*{#oc-requirements-status}

**Connection to an OpenShift cluster**

In order to execute this demo, you will need to have an OpenShift cluster with the correct access level, the ability to create projects and install operators as well as the Apache Camel K CLI installed on your local system.

[Check if you're connected to an OpenShift cluster](didact://?commandId=vscode.didact.requirementCheck&text=cluster-requirements-status$$oc%20get%20project%20camel-k-kafka&completion=OpenShift%20is%20connected. "Tests to see if `oc get project` returns a result"){.didact}

*Status: unknown*{#cluster-requirements-status}

**Apache Camel K CLI ("kamel")**

Apart from the support provided by the VS Code extension, you also need the Apache Camel K CLI ("kamel") in order to access all Camel K features.

[Check if the Apache Camel K CLI ("kamel") is installed](didact://?commandId=vscode.didact.requirementCheck&text=kamel-requirements-status$$kamel%20version$$Camel%20K%20Client&completion=Apache%20Camel%20K%20CLI%20is%20available%20on%20this%20system. "Tests to see if `kamel version` returns a result"){.didact}

*Status: unknown*{#kamel-requirements-status}

### Optional Requirements

The following requirements are optional. They don't prevent the execution of the demo, but may make it easier to follow.

**VS Code Extension Pack for Apache Camel**

The VS Code Extension Pack for Apache Camel by Red Hat provides a collection of useful tools for Apache Camel K developers,
such as code completion and integrated lifecycle management. They are **recommended** for the tutorial, but they are **not**
required.

You can install it from the VS Code Extensions marketplace.

[Check if the VS Code Extension Pack for Apache Camel by Red Hat is installed](didact://?commandId=vscode.didact.extensionRequirementCheck&text=extension-requirement-status$$redhat.apache-camel-extension-pack&completion=Camel%20extension%20pack%20is%20available%20on%20this%20system. "Checks the VS Code workspace to make sure the extension pack is installed"){.didact}

*Status: unknown*{#extension-requirement-status}

## 1. Preparing the project

We'll connect to the `camel-k-kafka` project and check the installation status.

To change project, open a terminal tab and type the following command:

```
oc project camel-k-kafka
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20project%20camel-k-kafka&completion=Project%20changed. "Switched to the project that will run Camel K Kafka example"){.didact})

## 2. Secret preparation

You will have 2 different authentication method available in the next sections: `SASL/Plain` or `SASL/OAUTHBearer`.

### SASL/Plain authentication method

You can take back the secret credentials provided earlier (`kafka bootstrap URL`,`service account id` and `service account secret`). Edit `application.properties` file filling those configuration. Now you can create a secret to contain the sensitive properties in the `application.properties` file that we will pass later to the running `Integration`s:

```
oc create secret generic kafka-props --from-file application.properties
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20create%20secret%20generic%20kafka-props%20--from-file%20application.properties&completion=Secret%20created. "Opens a new terminal and sends the command above"){.didact})

### SASL/OAUTHBearer authentication method

You can take back the secret credentials provided earlier (`kafka bootstrap URL`,`service account id`, `service account secret` and `Token endpoint URL`). Edit `application-oauth.properties` file filling those configuration. Now you can create a secret to contain the sensitive properties in the `application-oauth.properties` file that we will pass later to the running `Integration`s:

```
oc create secret generic kafka-props --from-file application-oauth.properties
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20create%20secret%20generic%20kafka-props%20--from-file%20application-oauth.properties&completion=Secret%20created. "Opens a new terminal and sends the command above"){.didact})

## 3. Running a Kafka Producer integration

At this stage, run a producer integration. This one will fill the topic with a message, every second:

```
kamel run --secret kafka-props SaslSSLKafkaProducer.java --dev
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20--secret%20kafka-props%20SaslSSLKafkaProducer.java%20--dev&completion=Camel%20K%20integration%20run%20in%20dev%20mode. "Opens a new terminal and sends the command above"){.didact})

The producer will create a new message and push into the topic and log some information.

```
...
[2] 2021-05-06 15:08:53,231 INFO  [FromTimer2Kafka] (Camel (camel-1) thread #7 - KafkaProducer[test]) Message correctly sent to the topic!
[2] 2021-05-06 15:08:54,155 INFO  [FromTimer2Kafka] (Camel (camel-1) thread #9 - KafkaProducer[test]) Message correctly sent to the topic!
...
```

> **Note:** Both `SaslSSLKafkaProducer.java` and `SaslSSLKafkaConsumer.java` files specify a runtime `kafka-clients` maven dependency needed in version `1.3.x` of Camel K. It may not be needed to specify it in future Camel K releases.

> **Note:** The integration files specify a runtime `kafka-oauth-client` maven dependency provided by Strimzi. This is only needed if you run the `SASL/OAUTHBearer` authentication method. You may be using a different service or provide your own implementation.

## 4. Running a Kafka Consumer integration

Now, open another shell and run the consumer integration using the command:

```
kamel run --secret kafka-props SaslSSLKafkaConsumer.java --dev
```

([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20run%20--secret%20kafka-props%20SaslSSLKafkaConsumer.java%20--dev&completion=Camel%20K%20integration%20run%20in%20dev%20mode. "Opens a new terminal and sends the command above"){.didact})

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
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20delete%20project%20camel-k-kafka&completion=Removed%20the%20project%20from%20the%20cluster. "Cleans up the cluster after running the example"){.didact})
