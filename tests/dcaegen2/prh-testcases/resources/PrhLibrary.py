import json

import docker
import time


class PrhLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def check_for_log(search_for):
        client = docker.from_env()
        container = client.containers.get('prh')
        print ("Check for log searches for pattern: ", search_for )
        for line in container.logs(stream=True):
            print ("Check for log analysis line: ", line )
            if search_for in line.strip():
                return True
        else:
            return False

    @staticmethod
    def create_invalid_notification(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = PrhLibrary.extract_correlation_id_value(json_to_python, "correlationId")
        ipv4 = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "oamV4IpAddress", "oamV4IpAddress")
        ipv6 = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "oamV6IpAddress", "oamV6IpAddress")
        serial_number = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "serialNumber", "serialNumber")
        vendor_name = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "vendorName", "vendorName")
        model_number = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "modelNumber", "modelNumber")
        unit_type = PrhLibrary.extract_value_from_pnfRegistrationFields(json_to_python, "unitType", "unitType")

        additional_fields = PrhLibrary.extract_additional_fields(json_to_python)

        str_json = '{' + correlation_id + ipv4 + ipv6 + serial_number + vendor_name + model_number + unit_type + '"nfNamingCode":""' + "," + '"softwareVersion":"",' + additional_fields
        return json.dumps(str_json).replace("\\", "")[1:-1].replace("\":", "\": ").rstrip(',') + '\\n}'

    @staticmethod
    def create_pnf_ready_notification_as_pnf_ready(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = PrhLibrary.extract_correlation_id_value(json_to_python, "correlationId")

        additional_fields = PrhLibrary.extract_additional_fields_value(json_to_python)

        str_json = '{' + correlation_id + additional_fields

        return json.dumps(str_json.rstrip(',') + '}').replace("\\", "")[1:-1]

    @staticmethod
    def extract_additional_fields_value(content):
        fields = PrhLibrary.get_additional_fields_as_key_value_pairs(content)
        if len(fields) == 0:
            return ""
        return PrhLibrary.build_additional_fields_json(fields)

    @staticmethod
    def extract_additional_fields(content):
        fields = PrhLibrary.get_additional_fields_as_key_value_pairs(content)
        if fields == []:
            return '"additionalFields":null'
        return PrhLibrary.build_additional_fields_json(fields)

    @staticmethod
    def get_additional_fields_as_key_value_pairs(content):
        return content.get("event").get("pnfRegistrationFields").get(
            "additionalFields") if "additionalFields" in content["event"]["pnfRegistrationFields"] else []

    @staticmethod
    def build_additional_fields_json(fields):
        res = '"additionalFields":{'
        for f in fields:
            res += '"' + f + '":"' + fields.get(f) + '",'
        return res.rstrip(',') + '},'

    @staticmethod
    def extract_value_from_pnfRegistrationFields(content, name, key):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get(key) + '",' if key in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_correlation_id_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("commonEventHeader").get("sourceName") + '",' if "sourceName" in content["event"]["commonEventHeader"] else '",')

    @staticmethod
    def create_pnf_name(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName") + '",' if "sourceName" in json_to_python["event"]["commonEventHeader"] else '",'
        return correlation_id

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
    def convert_json_2_string(json_file):
        dump =   json.dumps(json_file)
        return json.loads(dump)