# Camel K Kafka Service Binding Quickstart

This example demonstrates how to use `Camel K` and `Apache Kafka` with `Kamelets` and `Service Bindings`. [`Kamelets`](https://camel.apache.org/camel-k/latest/kamelets/kamelets.html) are the way of representing an event source and sink used by Camel K. [`Service Bindings`](https://github.com/redhat-developer/service-binding-operator) are a way to simplify access to services such as databases, queues or topics with no need to configure `Secret` or `Configmap`. You will see how you will be able to hook a service into an application in a few steps.

We'll use Red Hat OpenShift Streams for Apache Kafka for the following example. In order to use it, you must login to the [Red Hat Cloud (Beta)](https://cloud.redhat.com/beta/). Please, consider the due [limitations](https://access.redhat.com/articles/5979061) of this offering at the time of writing this tutorial.

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

## Preparing the cluster

This example can be run on any OpenShift 4.3+ cluster or a local development instance (such as [CRC](https://github.com/code-ready/crc)). Ensure that you have a cluster available and login to it using the OpenShift `oc` command line tool.

You need to create a new project named `camel-k-kafka` for running this example. This can be done directly from the OpenShift web console or by executing the command `oc new-project camel-k-kafka` on a terminal window.

```
oc new-project camel-k-kafka
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20new-project%20camel-k-kafka&completion=Project%20changed. "Switched to the project that will run Camel K Kafka example"){.didact})

You will need to install three operators: `Camel-K`, `RHOAS` and `Service Binding`.

### Camel K operator

You need to install the Camel K operator in the `camel-k-kafka` project. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"Red Hat Integration - Camel K"**. The `Service Binding` feature are available starting from version 1.4. If this version is not yet available for Red Hat Integration, you can use the **Community Camel K Operator** version 1.4 while waiting for Red Hat Integration version release cycle.

You will be given the option to install it globally on the cluster or on a specific namespace. If using a specific namespace, make sure you select the `camel-k-kafka` project from the dropdown list. This completes the installation of the Camel K operator (it may take a couple of minutes).

Upon successful creation, you should ensure that the Camel K operator is installed:

```
oc get csv
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20csv&completion=Checking%20Cluster%20Service%20Versions. "Opens a new terminal and sends the command above"){.didact})

When Camel K is installed, you should find an entry related to `red-hat-camel-k-operator` in phase `Succeeded`.

When the operator is installed, from the OpenShift Help menu ("?") at the top of the WebConsole, you can access the "Command Line Tools" page, where you can download the **"kamel"** CLI, that is required for running this example. The CLI must be installed in your system path.

Refer to the **"Red Hat Integration - Camel K"** documentation for a more detailed explanation of the installation steps for the operator and the CLI.

You can use the following section to check if your environment is configured properly.

### RHOAS operator

You need to install the **RHOAS operator**. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"(RHOAS) OpenShift Application Services"**. This operator is in charge to manage the communication between your Openshift Cluster and the Red Hat Openshift Streams for Apache Kafka instances.

> NOTE: this is a community operator at the time of this writing.

Upon successful creation, you should ensure that the Service Binding operator is installed:
```
oc get csv
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20csv&completion=Checking%20Cluster%20Service%20Versions. "Opens a new terminal and sends the command above"){.didact})

When Service Binding operator is installed, you should find an entry related to `rhoas-operator` in phase `Succeeded`.

As soon as the operator is installed, you will have to download and install the **RHOAS** CLI available at: https://github.com/redhat-developer/app-services-cli

[Check if the RHOAS CLI ("rhoas") is installed](didact://?commandId=vscode.didact.cliCommandSuccessful&text=rhoas-requirements-status$$rhoas%20help&completion=Checked%rhoas%20tool%20availability "Tests to see if `rhoas` returns a 0 return code"){.didact}

*Status: unknown*{#rhoas-requirements-status}

### Service Binding operator

You need to install the **Service Binding operator**. To do so, go to the OpenShift 4.x web console, login with a cluster admin account and use the OperatorHub menu item on the left to find and install **"Service Binding Operator"**. This operator is in charge to manage the `Service Binding` that are used by `Kamelet`.

You will be given the option to install it globally on the cluster or on a specific namespace. If using a specific namespace, make sure you select the `camel-k-kafka` project from the dropdown list.

Upon successful creation, you should ensure that the Service Binding operator is installed:
```
oc get csv
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20get%20csv&completion=Checking%20Cluster%20Service%20Versions. "Opens a new terminal and sends the command above"){.didact})

When Service Binding operator is installed, you should find an entry related to `service-binding-operator` in phase `Succeeded`.

You can now proceed to the next section.

## Preparing the application

We are using a simple event source/sink application to show how to produce/consume events to/from a Kafka topic. The application will be composed of two `Integration`, which are in charge to write and read from a topic respectively. Let's start by selecting the `camel-k-kafka` project if you're not already on it:

```
$ oc project camel-k-kafka
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20project%20camel-k-kafka&completion=Project%20changed. "Switched to the project that will run Camel K Kafka example"){.didact})

## 1. Configure Kafka instance and topics

We are now going to make use of the `rhoas` CLI. This is the easiest way to prepare the Kafka instances and connect to them. You will need to login:

```
$ rhoas login
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$rhoas%20login&completion=Logged%20in. "Opens a new terminal and sends the command above"){.didact})

Then, if you don't have yet an instance available, you can create one. We named this as `test`:

```
$ rhoas kafka create test
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$rhoas%20kafka%20create%20test&completion=Kafka%20created. "Opens a new terminal and sends the command above"){.didact})

This process may take up to a couple of minutes to complete. You can check the status running the following command:

```
$ rhoas kafka list
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$rhoas%20kafka%20list&completion=Kafka%20list. "Opens a new terminal and sends the command above"){.didact})

You must wait for the `status` to be equal to `ready`. At this stage you can create a new topic, if you don't have yet any available:

```
$ rhoas kafka topic create test
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$rhoas%20kafka%20topic%20create%20test&completion=Topic%20created. "Opens a new terminal and sends the command above"){.didact})

The creation of a `Topic` is immediate. Now, you have to connect now your cluster with the Openshift Application Services instances:

```
$ rhoas cluster connect
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$rhoas%20cluster%20connect&completion=Cluster%20connected. "Opens a new terminal and sends the command above"){.didact})

This command may require you to get some credential token in the console. So, follow up the instructions and copy/paste the token. Once completed you should see the following output:

```
    Token Secret "rh-cloud-services-accesstoken-cli" created successfully
    Service Account Secret "rh-cloud-services-service-account" created successfully
    KafkaConnection resource "test" has been created
```
Basically, that means that the RHOAS has set up all the needed configuration that is eventually required for the `Service Binding`. In particular we'll use the `KafkaConnection` custom resource named `test`.

## 2. Configure Camel K Kamelets

Now it's turn to configure all the required `Kamelet` for our application. You can use any of the `Kamelet` provided out of the box, or, create new ones, as we're doing in this example.

We'll use a `beer-source` which is in charge to create a new beer event (a json text with a random beer) every 5 seconds. Then we'll use a `managed-kafka-sink` which is pushing the event to a Kafka topic. We'll use these `Kamelet` in a `beers-to-kafka` `KameletBinding` which will be in charge to take the events and just push to the topic.

On the consumer side, we'll use a `managed-kafka-source`, whose goal is to consume events from a Kafka topic and a `log-sink` `Kamelet`, which will simply write to log an event. We'll use these `Kamelet` in a `kafka-to-log` `KameletBinding` which will be in charge to take the events and write to log.

Let's start by creating the Kamelets:
```
$ oc apply -f beer-source.kamelet.yaml
$ oc apply -f managed-kafka-sink.kamelet.yaml
$ oc apply -f managed-kafka-source.kamelet.yaml
$ oc apply -f log-sink.kamelet.yaml
$ oc get kamelets
NAME                   PHASE
beer-source            Ready
log-sink               Ready
managed-kafka-sink     Ready
managed-kafka-source   Ready
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20apply%20-f%20beer-source.kamelet.yaml%0Aoc%20apply%20-f%20managed-kafka-sink.kamelet.yaml%0Aoc%20apply%20-f%20managed-kafka-source.kamelet.yaml%0Aoc%20apply%20-f%20log-sink.kamelet.yaml%0Aoc%20get%20kamelets&completion=Kamelets%20created. "Opens a new terminal and sends the command above"){.didact})

## 3. Running an event producer

We can now create an event producer `Integration`. The goal is to get the `beer-source` and to push to a Kafka topic via `managed-kafka-sink`. We can create a `KameletBinding` for this purpose:

```
$ oc apply -f beers-to-kafka.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20apply%20-f%20beers-to-kafka.yaml&completion=Integration%20created. "Opens a new terminal and sends the command above"){.didact})

We can have a look at the `Integration` log, altough, in this case it won't log too much. However, it's useful to see if it is producing any error:

```
$ kamel logs beers-to-kafka -n camel-k-kafka
...
[1] 2021-06-21 07:48:12,696 INFO  [io.quarkus] (main) camel-k-integration 1.4.0 on JVM (powered by Quarkus 1.13.0.Final) started in 2.790s. 
...
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20logs%20beers-to-kafka%20-n%20camel-k-kafka&completion=Log%20command. "Opens a new terminal and sends the command above"){.didact})

### Understading the Service Binding
In order to understand how the `Service Binding` works, it's worth to take a look at how the `KameletBinding` is configured:

```
spec:
  integration:
    traits:
      service-binding:
        configuration:
          serviceBindings:
          - rhoas.redhat.com/v1alpha1:KafkaConnection:test
  source:
...
  sink:
...
    properties:
      topic: test
```
You can notice that we had to specify a `service-binding` trait configuration which is pointing to the `KafkaConnection:test` that we created previously. With this configuration, we'll tell the various operators involved to cooperate in order to resolve the configuration parameters defined in the `managed-kafka-sink` Kamelet.

## 4. Running an event consumer

Now, open another shell and run the consumer integration. The goal is to get the `managed-kafka-source` events and print out to a log with the `log-sink` Kamelet. We can create a `KameletBinding` for this purpose:

```
$ oc apply -f kafka-to-log.yaml
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20apply%20-f%20kafka-to-log.yaml&completion=Integration%20created. "Opens a new terminal and sends the command above"){.didact})

The log here will give us a new beer event as soon as this is created by the producer `Integration`:

```
$ kamel logs kafka-to-log
...
[1] 2021-06-21 07:51:59,388 INFO  [sink] (Camel (camel-1) thread #0 - KafkaConsumer[test]) Exchange[ExchangePattern: InOnly, BodyType: String, Body: {"id":5132,"uid":"41c76ca1-c134-4eab-af73-41276345142a","brand":"Sierra Nevada","name":"Two Hearted Ale","style":"Light Hybrid Beer","hop":"Galena","yeast":"3056 - Bavarian Wheat Blend","malts":"Caramel","ibu":"56 IBU","alcohol":"5.0%","blg":"6.8°Blg"}]
[1] 2021-06-21 07:52:04,452 INFO  [sink] (Camel (camel-1) thread #0 - KafkaConsumer[test]) Exchange[ExchangePattern: InOnly, BodyType: String, Body: {"id":7685,"uid":"9a84d4aa-b06c-4aec-ad63-c3da3c71fbbe","brand":"Budweiser","name":"Ten FIDY","style":"German Wheat And Rye Beer","hop":"Fuggle","yeast":"2308 - Munich Lager","malts":"Carapils","ibu":"22 IBU","alcohol":"5.8%","blg":"16.4°Blg"}]
...
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$kamel%20logs%20kafka-to-log&completion=Log%20command. "Opens a new terminal and sends the command above"){.didact})

The `ServiceBinding` mechanism is the same we've seen in the producer `Integration`.

## 5. Uninstall

To cleanup everything, execute the following command:

```
oc delete project camel-k-kafka
```
([^ execute](didact://?commandId=vscode.didact.sendNamedTerminalAString&text=camelTerm$$oc%20delete%20project%20camel-k-kafka&completion=Removed%20the%20project%20from%20the%20cluster. "Cleans up the cluster after running the example"){.didact})
