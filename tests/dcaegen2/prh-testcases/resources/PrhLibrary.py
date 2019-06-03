import json

import docker
import time


class PrhLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def find_log_entry(search_for):
        print (type(search_for))
        client = docker.from_env()
        container = client.containers.get('prh')
        # print ("Check for log searches for pattern: ", search_for )
        for line in container.logs(stream=True):
            # print ("Check for log analysis line: ", line )
            if search_for in line.strip():
                return True
        else:
            return False

    @staticmethod
    def create_invalid_notification(json_file):
        output = {}
        input = json.loads(json_file)[0]

        output["correlationId"] = PrhLibrary.__extract_correlation_id_value(input)
        output["oamV4IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV4IpAddress")
        output["oamV6IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV6IpAddress")
        output["serialNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "serialNumber")
        output["vendorName"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "vendorName")
        output["modelNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "modelNumber")
        output["unitType"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "unitType")
        output['nfNamingCode'] = ''
        output['softwareVersion'] = ''

        additional_fields = PrhLibrary.__get_additional_fields_as_key_value_pairs(input)
        if len(additional_fields) > 0:
            output["additionalFields"] = additional_fields

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

        additional_fields = PrhLibrary.__get_additional_fields_as_key_value_pairs(input)
        if len(additional_fields) > 0:
            output["additionalFields"] = additional_fields

        return json.dumps(output)

    @staticmethod
    def __get_additional_fields_as_key_value_pairs(content):
        return content.get("event").get("pnfRegistrationFields").get(
            "additionalFields") if "additionalFields" in content["event"]["pnfRegistrationFields"] else []

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

#OLD ONES:

    @staticmethod
    def create_pnf_name(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName") + '",' if "sourceName" in json_to_python["event"]["commonEventHeader"] else '",'
        return correlation_id