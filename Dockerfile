# Apache Kafka

FROM openjdk:8-jre-alpine

MAINTAINER ogergardt

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

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin

ADD start.sh ${KAFKA_HOME}/bin/start.sh
RUN chmod +x ${KAFKA_HOME}/bin/start.sh

ADD download.sh /tmp/download.sh
RUN chmod a+x /tmp/download.sh \
  && sync && /tmp/download.sh \
  && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
  && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
  && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} $KAFKA_HOME \
  && chown -R root:root $KAFKA_HOME

RUN addgroup -S kafka \
  && adduser -h /var/lib/kafka -G kafka -S -H -s /sbin/nologin kafka \
  && mkdir /var/lib/kafka && chown -R kafka:kafka /var/lib/kafka \
  && mkdir /var/log/kafka && chown -R kafka:kafka /var/log/kafka

EXPOSE 9092

VOLUME ["/var/lib/kafka", "/var/log/kafka"]

ENTRYPOINT ["start.sh"]
