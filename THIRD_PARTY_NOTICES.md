# Third-Party Notices

Repository: `kafka-connect-image`

This repository is intended to be published under the **MIT License** for project-owned files such as the Dockerfile, README, templates and helper documentation.

The built container image includes third-party software that remains under its own licenses. This file documents the main third-party components included or downloaded by the current Dockerfile.

This file is provided for convenience and is not legal advice. For formal redistribution, verify the exact container image contents and include the license files/notices required by every component actually shipped in the image.

---

## Project-owned files

| Component | Usage | License |
|---|---|---|
| `kafka-connect-image` Dockerfile and repository documentation | builds a custom Kafka Connect image | MIT |

Recommended project files:

```text
LICENSE
THIRD_PARTY_NOTICES.md
```

---

## Current image build summary

The current Dockerfile builds a custom Kafka Connect image in two stages.

### Stage 1: SMT build image

Base image:

```text
docker.io/library/maven:3.9.12-eclipse-temurin-17
```

Purpose:

```text
clone envsensor-kafka-smt, build it with Maven, copy the shaded JAR to the final image
```

This stage is not part of the final runtime image unless the build system preserves intermediate layers.

### Stage 2: runtime image

Base image:

```text
quay.io/strimzi/kafka:0.49.1-kafka-4.1.1
```

Installed/downloaded components:

| Component | Version/source | Installed path | License / notice |
|---|---|---|---|
| Strimzi Kafka Connect base image | `quay.io/strimzi/kafka:0.49.1-kafka-4.1.1` | base image | Strimzi and Kafka components are generally Apache License 2.0; base image also contains OS packages under their own licenses |
| Apache Kafka / Kafka Connect runtime | included in Strimzi image | base image | Apache License 2.0 |
| Stream Reactor MQTT Source connector | `STREAM_REACTOR_VERSION=11.3.0` from `lensesio/stream-reactor` release ZIP | `/opt/kafka/plugins/mqtt` | Apache License 2.0 according to the Stream Reactor project |
| Confluent Amazon S3 Sink Connector | `CONFLUENT_S3_VERSION=12.0.0` from Confluent Hub ZIP | `/opt/kafka/plugins/confluentinc-kafka-connect-s3-12.0.0` | Confluent Community License Version 1.0 |
| `envsensor-kafka-smt` | built from `https://github.com/pvamos/envsensor-kafka-smt.git` | `/opt/kafka/plugins/envsensor-smt/envsensor-smt.jar` | MIT for project code, plus shaded protobuf license notice |

---

## Strimzi Kafka base image

Base image:

```text
quay.io/strimzi/kafka:0.49.1-kafka-4.1.1
```

Main included runtime:

```text
Apache Kafka / Kafka Connect 4.1.1
```

Typical license:

```text
Apache License 2.0 for Apache Kafka and Strimzi project components
```

Sources:

```text
https://strimzi.io/
https://github.com/strimzi/strimzi-kafka-operator
https://kafka.apache.org/
https://github.com/apache/kafka
```

License text:

```text
https://www.apache.org/licenses/LICENSE-2.0
```

Redistribution note:

The base image contains many OS and Java dependencies. When redistributing a derived container image, review the base image's own license and package notices/SBOM where available.

---

## Stream Reactor MQTT Source connector

Component:

```text
Lenses Stream Reactor MQTT Source connector
```

Dockerfile arguments:

```text
STREAM_REACTOR_VERSION=11.3.0
MQTT_ARTIFACT=kafka-connect-mqtt-${STREAM_REACTOR_VERSION}.zip
```

Download source:

```text
https://github.com/lensesio/stream-reactor/releases/download/${STREAM_REACTOR_VERSION}/${MQTT_ARTIFACT}
```

Installed path:

```text
/opt/kafka/plugins/mqtt
```

Typical connector class:

```text
com.datamountaineer.streamreactor.connect.mqtt.source.MqttSourceConnector
```

License:

```text
Apache License 2.0
```

Source:

```text
https://github.com/lensesio/stream-reactor
```

Redistribution note:

Include the license/notice files packaged in the downloaded Stream Reactor ZIP when redistributing the final image.

---

## Confluent Amazon S3 Sink Connector

Component:

```text
Amazon S3 Sink Connector for Confluent Platform
```

Dockerfile arguments:

```text
CONFLUENT_S3_VERSION=12.0.0
CONFLUENT_S3_ZIP=confluentinc-kafka-connect-s3-${CONFLUENT_S3_VERSION}.zip
CONFLUENT_S3_URL=https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-s3/versions/${CONFLUENT_S3_VERSION}/${CONFLUENT_S3_ZIP}
```

Installed path:

```text
/opt/kafka/plugins/confluentinc-kafka-connect-s3-12.0.0
```

Connector class:

```text
io.confluent.connect.s3.S3SinkConnector
```

Documentation:

```text
https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html
```

License:

```text
Confluent Community License Version 1.0
```

License text:

```text
https://www.confluent.io/confluent-community-license/
```

Redistribution note:

The Confluent Amazon S3 Sink Connector is source-available under the Confluent Community License. The license allows access, modification and redistribution, but excludes making available a SaaS/PaaS/IaaS or similar online service that competes with Confluent products or services that provide the licensed software.

Include the Confluent Community License and any license/notice files packaged in the downloaded connector ZIP when redistributing the image.

---

## envsensor-kafka-smt

Component:

```text
envsensor-kafka-smt
```

Build source:

```text
https://github.com/pvamos/envsensor-kafka-smt.git
```

Current Dockerfile defaults:

```text
SMT_REPO=https://github.com/pvamos/envsensor-kafka-smt.git
SMT_REF=main
SMT_SUBDIR=.
SMT_MVN_ARGS=-DskipTests package
SMT_JAR_GLOB=target/*-all.jar
```

Installed path in the current Dockerfile:

```text
/opt/kafka/plugins/envsensor-smt/envsensor-smt.jar
```

License:

```text
MIT for project-owned SMT source code
```

Additional dependency note:

The SMT shaded JAR includes the Protocol Buffers Java runtime. Include the protobuf license notice when redistributing the final image.

---

## Protocol Buffers Java runtime

Used by:

```text
envsensor-kafka-smt shaded plugin JAR
```

Artifact:

```text
com.google.protobuf:protobuf-java
```

License:

```text
BSD-style protobuf license
```

Project/source:

```text
https://github.com/protocolbuffers/protobuf
```

License text:

```text
https://github.com/protocolbuffers/protobuf/blob/main/LICENSE
```

Redistribution note:

The protobuf runtime is included inside the SMT shaded JAR. Preserve the protobuf license notice in image-level notices.

---

## OS packages installed during image build

The Dockerfile installs packages in the runtime stage:

```text
unzip
tar
```

The base image package manager may also update existing packages:

```text
microdnf update -y
```

Redistribution note:

OS packages remain under their own licenses. Review the final image package list/SBOM for a complete license inventory.

Suggested inspection commands:

```bash
podman run --rm <image> rpm -qa | sort
podman image inspect <image>
```

---

## GitHub token build secret

The build supports an optional secret:

```text
--secret id=github_token,src=.github_token
```

This is not a third-party dependency and must never be committed or included in the image.

If a real token was committed, revoke it and create a new one.

---

## Suggested image-level license layout

When publishing the container image, include a license/notice directory such as:

```text
/licenses/
  kafka-connect-image-LICENSE.txt
  apache-2.0-LICENSE.txt
  confluent-community-license-1.0.txt
  protobuf-LICENSE.txt
  stream-reactor-LICENSE.txt
  strimzi-LICENSE.txt
  kafka-LICENSE.txt
  kafka-NOTICE.txt
/THIRD_PARTY_NOTICES.md
```

Adjust this list to match the exact image contents.

---

## Practical release checklist

Before publishing the repository:

- [ ] Keep the repository `LICENSE` file as the MIT License for project-owned files.
- [ ] Keep this `THIRD_PARTY_NOTICES.md` file.
- [ ] Keep `.github_token` out of Git.
- [ ] Replace real registry names, image tags, Kafka topic names and deployment values with placeholders.
- [ ] Do not commit registry credentials, GitHub tokens, S3 keys or MQTT passwords.

Before publishing the container image:

- [ ] Include the Confluent Community License for the Confluent Amazon S3 Sink Connector.
- [ ] Include Apache 2.0 license/notice files for Kafka, Strimzi and Stream Reactor components.
- [ ] Include protobuf license notices for the shaded SMT dependency.
- [ ] Review the downloaded connector ZIP contents for bundled dependency notices.
- [ ] Review the base image/SBOM/package list for OS-level licenses.
- [ ] Do not bake runtime secrets into the image.

---

## Known license summary

| Distributed item | License responsibility |
|---|---|
| Source repository only | MIT for project-owned files; third-party notices are still useful |
| Built Kafka Connect image | MIT for project-owned files + Strimzi/Kafka/Stream Reactor/Confluent/protobuf/base-image notices |
| Confluent Amazon S3 Sink Connector | Confluent Community License Version 1.0 |
| Stream Reactor MQTT connector | Apache License 2.0 |
| Kafka / Kafka Connect runtime | Apache License 2.0 |
| Strimzi project components | Apache License 2.0 |
| Protocol Buffers runtime inside SMT JAR | BSD-style protobuf license |

---

## References

- MIT License: `https://spdx.org/licenses/MIT.html`
- Apache License 2.0: `https://www.apache.org/licenses/LICENSE-2.0`
- Confluent Amazon S3 Sink Connector documentation: `https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html`
- Confluent Community License: `https://www.confluent.io/confluent-community-license/`
- Strimzi: `https://strimzi.io/`
- Apache Kafka: `https://kafka.apache.org/`
- Stream Reactor: `https://github.com/lensesio/stream-reactor`
- Protocol Buffers license: `https://github.com/protocolbuffers/protobuf/blob/main/LICENSE`
