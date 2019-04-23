# ============LICENSE_START====================================
# csit-dcaegen2-collectors-hv-ves
# =========================================================
# Copyright (C) 2019 Nokia. All rights reserved.
# =========================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=====================================

import docker
from robot.api import logger

KAFKA_IMAGE_FULL_NAME = "nexus3.onap.org:10001/onap/dmaap/kafka111:0.0.6"
KAFKA_ADDRESS = "kafka:9092"
ZOOKEEPER_ADDRESS = "zookeeper:2181"

LIST_TOPICS_COMMAND = "kafka-topics.sh --list --zookeeper %s" % ZOOKEEPER_ADDRESS
TOPIC_STATUS_COMMAND = "kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list " + KAFKA_ADDRESS + " --topic %s --time -1"
DELETE_TOPIC_COMMAND = "kafka-topics.sh --zookeeper " + ZOOKEEPER_ADDRESS + " --delete --topic %s"


class KafkaLibrary:

    def log_kafka_status(self):
        dockerClient = docker.from_env()
        kafka = dockerClient.containers.list(filters={"ancestor": KAFKA_IMAGE_FULL_NAME}, all=True)[0]

        topics = self.get_topics(kafka)
        logger.info("Topics initialized in Kafka cluster: " + str(topics))
        for topic in topics:
            if topic == "__consumer_offsets":
                # kafka-internal topic, ignore it
                continue

            self.log_topic_status(kafka, topic)
            self.reset_topic(kafka, topic)

        dockerClient.close()

    def get_topics(self, kafka):
        exitCode, output = kafka.exec_run(LIST_TOPICS_COMMAND)
        return output.splitlines()

    def log_topic_status(self, kafka, topic):
        _, topic_status = kafka.exec_run(TOPIC_STATUS_COMMAND % topic)
        logger.info("Messages on topic: " + str(topic_status))

    def reset_topic(self, kafka, topic):
        logger.info("Removing topic " + str(
            topic) + " (note that it will be recreated by dcae-app-simulator/hv-ves-collector, however the offset will be reseted)")
        _, output = kafka.exec_run(DELETE_TOPIC_COMMAND % topic)
        logger.info(str(output))
