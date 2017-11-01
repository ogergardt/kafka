# Apache Kafka

FROM openjdk:8-jre-alpine

MAINTAINER Oleksandr Gergardt <ogergardt@gmail.com>

RUN \
  apk update
RUN \
  apk add --no-cache \
  wget \
  bash \
  curl \
  jq 

ARG KAFKA_VERSION=0.11.0.1
ARG SCALA_VERSION=2.12

LABEL name="kafka" version=${KAFKA_VERSION}

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ENV PATH ${PATH}:${KAFKA_HOME}/bin
RUN mkdir -p "$KAFKA_HOME"

ADD download.sh /tmp/download.sh
RUN chmod a+x /tmp/download.sh \
  && /tmp/download.sh \
  && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
  && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
  && chown -R root:root $KAFKA_HOME

ADD start.sh ${KAFKA_HOME}/bin/start.sh
RUN chmod +x ${KAFKA_HOME}/bin/start.sh

RUN addgroup -S kafka \
  && adduser -h /var/lib/kafka -G kafka -S -H -s /sbin/nologin kafka \
  && mkdir /var/lib/kafka && chown -R kafka:kafka /var/lib/kafka \
  && mkdir /var/log/kafka && chown -R kafka:kafka /var/log/kafka

EXPOSE 9092

VOLUME ["/var/lib/kafka", "/var/log/kafka"]

ENTRYPOINT ["start.sh"]


