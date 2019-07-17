import json
import re
import docker
import time
import datetime


class PrhLibrary(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self

    def _start_test(self, name, attrs):
        # http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#test-libraries-as-listeners
        self.test_start_time = self.get_current_utc_datetime()

    @staticmethod
    def get_current_utc_datetime():
        return datetime.datetime.utcnow()

    def get_docker_logs_since_test_start(self, container_id):
        return self.get_docker_logs(container_id, self.test_start_time)

    @staticmethod
    def get_docker_logs(container_id, since=None):
        container = PrhLibrary.__get_docker_container(container_id)
        return container.logs(stream=False, since=since)

    def wait_for_one_of_docker_log_entries(self, container_id, searched_entries):
        print("Looking for: %s" % searched_entries)
        container = PrhLibrary.__get_docker_container(container_id)
        print("Log lines:")
        for line in container.logs(stream=True, since=self.test_start_time):
            print(line)
            for searched_entry in searched_entries:
                if searched_entry in line.strip():
                    return True
        else:
            return False

    def wait_for_log_entry_with_json_message(self, prefix, json_message):
        print("Looking for:")
        print("Prefix: " + str(prefix))
        print("Json: " + str(json_message))
        try:
            decoded_message = json.loads(json_message)
        except json.JSONDecodeError:
            print("Could not decode given message")
            return False
        pattern = re.compile(prefix + "(.*)$")
        container = PrhLibrary.__get_docker_container('prh')
        print("Log lines:")
        for line in container.logs(stream=True, since=self.test_start_time):
            print(line)
            if PrhLibrary.__same_json_in_log(decoded_message, line, pattern):
                return True
        else:
            return False

    @staticmethod
    def create_invalid_notification(json_file):
        output = {}
        input = json.loads(json_file)
        output["correlationId"] = PrhLibrary.__extract_correlation_id_value(input)
        output["oamV4IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV4IpAddress")
        output["oamV6IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV6IpAddress")
        output["serialNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "serialNumber")
        output["vendorName"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "vendorName")
        output["modelNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "modelNumber")
        output["unitType"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "unitType")
        output['nfNamingCode'] = ''
        output['softwareVersion'] = ''

        output["additionalFields"] = PrhLibrary.__get_additional_fields_as_key_value_pairs(input)

        return json.dumps(output)

    @staticmethod
    def create_pnf_ready_notification_as_pnf_ready(json_file):
        output = {}
        input = json.loads(json_file)[0]

        output["correlationId"] = PrhLibrary.__extract_correlation_id_value(input)
        output["serialNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "serialNumber")
        output["equip-vendor"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "vendorName")
        output["equip-model"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "modelNumber")
        output["equip-type"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "unitType")
        output["nf-role"] = PrhLibrary.__extract_nf_role(input)
        output["sw-version"] = ""

        output["additionalFields"] = PrhLibrary.__get_additional_fields_as_key_value_pairs(input)

        return json.dumps(output)

    @staticmethod
    def ensure_container_is_running(name):
        client = docker.from_env()

        if not PrhLibrary.is_in_status(client, name, "running"):
            print ("starting container", name)
            container = client.containers.get(name)
            container.start()
            PrhLibrary.wait_for_status(client, name, "running")

        PrhLibrary.print_status(client)

    @staticmethod
    def ensure_container_is_exited(name):
        client = docker.from_env()

        if not PrhLibrary.is_in_status(client, name, "exited"):
            print ("stopping container", name)
            container = client.containers.get(name)
            container.stop()
            PrhLibrary.wait_for_status(client, name, "exited")

        PrhLibrary.print_status(client)

    @staticmethod
    def print_status(client):
        print("containers status")
        for c in client.containers.list(all=True):
            print(c.name, "   ", c.status)

    @staticmethod
    def wait_for_status(client, name, status):
        while not PrhLibrary.is_in_status(client, name, status):
            print ("waiting for container: ", name, "to be in status: ", status)
            time.sleep(3)

    @staticmethod
    def is_in_status(client, name, status):
        return len(client.containers.list(all=True, filters={"name": "^/"+name+"$", "status": status})) == 1

    @staticmethod
    def create_pnf_name(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName") + '",' if "sourceName" in json_to_python["event"]["commonEventHeader"] else '",'
        return correlation_id

    @staticmethod
    def __get_additional_fields_as_key_value_pairs(content):
        return content.get("event").get("pnfRegistrationFields").get(
            "additionalFields") if "additionalFields" in content["event"]["pnfRegistrationFields"] else {}

    @staticmethod
    def __extract_value_from_pnfRegistrationFields(content, key):
        return content["event"]["pnfRegistrationFields"][key] if key in content["event"]["pnfRegistrationFields"] else ''

    @staticmethod
    def __extract_correlation_id_value(content):
        return content["event"]["commonEventHeader"]["sourceName"] if "sourceName" in content["event"]["commonEventHeader"] else ''

    @staticmethod
    def __extract_nf_role(content):
        return content["event"]["commonEventHeader"]["nfNamingCode"] if "nfNamingCode" in content["event"]["commonEventHeader"] else ''

    @staticmethod
    def __same_json_in_log(decoded_message, line, pattern):
        extracted_json = PrhLibrary.__extract_json(line, pattern)
        if extracted_json is not None:
            print("Found json: " + extracted_json)
            try:
                if json.loads(extracted_json) == decoded_message:
                    return True
            except json.JSONDecodeError:
                print("Could not decode")
        return False

    @staticmethod
    def __extract_json(line, pattern):
        full_message = PrhLibrary.__extract_full_message_from_line(line)
        if full_message is not None:
            match = pattern.match(full_message)
            if match:
                return match.group(1).replace("\\n", "\n").replace("\\t", "\t")
        return None

    @staticmethod
    def __extract_full_message_from_line(line):
        split = line.split("|")
        if len(split) > 3:
            return split[3]
        return None

    @staticmethod
    def __get_docker_container(container_id):
        docker_client = docker.from_env()
        return docker_client.containers.get(container_id)
