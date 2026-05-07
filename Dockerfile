# syntax=docker/dockerfile:1.6

# ------------------------------------------------------------------------------
# Stage 1: Build envsensor SMT jar from GitHub
# ------------------------------------------------------------------------------
FROM docker.io/library/maven:3.9.12-eclipse-temurin-17 AS smt-build

ARG SMT_REPO="https://github.com/pvamos/envsensor-kafka-smt.git"
ARG SMT_REF="main"
ARG SMT_SUBDIR="."              # if the Maven project is in a subdir, set it here
ARG SMT_MVN_ARGS="-DskipTests package"
ARG SMT_JAR_GLOB="target/*-all.jar"

# Cache-buster for the git clone layer
ARG SMT_CACHEBUST=0

WORKDIR /work

# Install git (Debian-based Maven image)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Clone + checkout ref (branch/tag/sha)
RUN --mount=type=secret,id=github_token,required=false \
    set -eu; \
    echo "SMT_CACHEBUST=${SMT_CACHEBUST}"; \
    mkdir -p repo; \
    if [ -f /run/secrets/github_token ]; then \
      token="$(cat /run/secrets/github_token)"; \
      git clone --depth 1 --branch "${SMT_REF}" "https://${token}@${SMT_REPO#https://}" repo; \
    else \
      git clone --depth 1 --branch "${SMT_REF}" "${SMT_REPO}" repo; \
    fi

# Build
WORKDIR /work/repo/${SMT_SUBDIR}

# If you use BuildKit, this speeds up rebuilds:
# RUN --mount=type=cache,target=/root/.m2 mvn -U ${SMT_MVN_ARGS}
RUN set -eux; \
    mvn -U ${SMT_MVN_ARGS}; \
    ls -lah target || true; \
    test -n "$(ls -1 ${SMT_JAR_GLOB} 2>/dev/null | head -n1)"

# Copy the jar to a stable location for the final stage
RUN set -eux; \
    JAR="$(ls -1 ${SMT_JAR_GLOB} | head -n1)"; \
    cp -v "${JAR}" /work/envsensor-smt.jar


# ------------------------------------------------------------------------------
# Stage 2: Final Kafka Connect image (Strimzi base) + connectors + SMT
# ------------------------------------------------------------------------------
FROM quay.io/strimzi/kafka:0.49.1-kafka-4.1.1

USER root:root

RUN mkdir -p /opt/kafka/plugins

# Install tools needed to fetch/extract connectors
RUN set -eux; \
    microdnf update -y; \
    microdnf install -y unzip tar; \
    microdnf clean all

# -------------------- Stream Reactor MQTT Source --------------------
RUN mkdir -p /opt/kafka/plugins/mqtt

ARG STREAM_REACTOR_VERSION=11.3.0
ARG MQTT_ARTIFACT="kafka-connect-mqtt-${STREAM_REACTOR_VERSION}.zip"

RUN set -eux; \
    curl -fsSL -o "/tmp/${MQTT_ARTIFACT}" \
      "https://github.com/lensesio/stream-reactor/releases/download/${STREAM_REACTOR_VERSION}/${MQTT_ARTIFACT}"; \
    unzip "/tmp/${MQTT_ARTIFACT}" -d /opt/kafka/plugins/mqtt; \
    rm -f "/tmp/${MQTT_ARTIFACT}"

# -------------------- Confluent S3 Sink --------------------
ARG CONFLUENT_S3_VERSION=12.0.0
ARG CONFLUENT_S3_ZIP="confluentinc-kafka-connect-s3-${CONFLUENT_S3_VERSION}.zip"
ARG CONFLUENT_S3_URL="https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-s3/versions/${CONFLUENT_S3_VERSION}/${CONFLUENT_S3_ZIP}"

RUN set -eux; \
    curl -fsSL -o "/tmp/${CONFLUENT_S3_ZIP}" "${CONFLUENT_S3_URL}"; \
    unzip -q "/tmp/${CONFLUENT_S3_ZIP}" -d /opt/kafka/plugins; \
    rm -f "/tmp/${CONFLUENT_S3_ZIP}"; \
    test -d "/opt/kafka/plugins/confluentinc-kafka-connect-s3-${CONFLUENT_S3_VERSION}/lib"

# -------------------- envsensor SMT plugin --------------------
RUN mkdir -p /opt/kafka/plugins/envsensor-smt

# Copy the built jar from stage 1
COPY --from=smt-build /work/envsensor-smt.jar /opt/kafka/plugins/envsensor-smt/envsensor-smt.jar

# Permissions for Connect user (uid 1001)
RUN set -eux; \
    chown -R 1001:0 /opt/kafka/plugins; \
    chmod -R g+rx /opt/kafka/plugins

USER 1001
