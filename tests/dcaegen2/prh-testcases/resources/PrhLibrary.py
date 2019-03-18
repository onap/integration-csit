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
        ipv4 =  PrhLibrary.extract_ip_v4_value(json_to_python, "oamV4IpAddress")
        ipv6 = PrhLibrary.extract_ip_v6_value(json_to_python, "oamV6IpAddress")
        correlation_id = PrhLibrary.extract_correlation_id_value(json_to_python, "correlationId")
        serial_number = PrhLibrary.extract_serial_number_value(json_to_python, "serialNumber")
        vendor_name = PrhLibrary.extract_vendor_name_value(json_to_python, "vendorName")
        model_number = PrhLibrary.extract_model_number_value(json_to_python, "modelNumber")
        unit_type = PrhLibrary.extract_unit_type_value(json_to_python, "unitType")
        additional_fields = PrhLibrary.extract_additional_fields(json_to_python, "additionalFields")

        str_json = '{' + correlation_id + ipv4 + ipv6 + serial_number + vendor_name + model_number + unit_type + '"nfNamingCode":""' + "," + '"softwareVersion":"",' + additional_fields
        # str_json = str_json.rstrip(',') + '}'

        return json.dumps(str_json).replace("\\", "")[1:-1].replace("\":", "\": ").rstrip(',') + '\\n}'
        # return python_to_json.replace("\\", "")[1:-1].replace("\":", "\": ")
        # return python_to_json[1:-1].replace("\":", "\": ")

    @staticmethod
    def create_pnf_ready_notification_as_pnf_ready(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = PrhLibrary.extract_correlation_id_value(json_to_python, "correlationId")
        serial_number = PrhLibrary.extract_serial_number_value(json_to_python, "serial-number")
        vendor_name = PrhLibrary.extract_vendor_name_value(json_to_python, "equip-vendor")
        model_number = PrhLibrary.extract_model_number_value(json_to_python, "equip-model")
        unit_type = PrhLibrary.extract_unit_type_value(json_to_python, "equip-type")
        additional_fields = PrhLibrary.extract_additional_fields_value(json_to_python, "additionalFields")

        nf_role  = json_to_python.get("event").get("commonEventHeader").get("nfNamingCode") if "nfNamingCode" in json_to_python["event"]["commonEventHeader"] else ""

        str_json = '{' + correlation_id + serial_number + vendor_name + model_number + unit_type + '"nf-role":"' + nf_role + '","sw-version":"",' + additional_fields
        str_json = str_json.rstrip(',') + '}'

        # python_to_json = json.dumps(str_json)
        # return python_to_json.replace("\\", "")[1:-1]

        # python_to_json = json.dumps(str_json)
        return json.dumps(str_json).replace("\\", "")[1:-1]

    @staticmethod
    def extract_additional_fields(content, name):
        fields = content.get("event").get("pnfRegistrationFields").get(name) if name in content["event"]["pnfRegistrationFields"] else []
        if fields == []:
            return '"' + name + '":' + 'null' + '\\\\n'
        res = '"' + name + '":{'
        for f in fields:
            res += '"' + f + '"' + ':' + '"' + fields.get(f) + '",'
        return res.rstrip(',') + '},'

    @staticmethod
    def extract_additional_fields_value(content, name):
        fields = content.get("event").get("pnfRegistrationFields").get(name) if name in content["event"]["pnfRegistrationFields"] else []
        if fields == [] or len(fields) == 0:
            return ""
        res = '"' + name + '":{'
        for f in fields:
            res += '"' + f + '"' + ':' + '"' + fields.get(f) + '",'
        return res.rstrip(',') + '},'

    @staticmethod
    def extract_ip_v4(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("oamV4IpAddress") + '",') if "oamV4IpAddress" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_ip_v4_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("oamV4IpAddress") + '",' if "oamV4IpAddress" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_ip_v6(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") + '",') if "oamV6IpAddress" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_ip_v6_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") + '",' if "oamV6IpAddress" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_correlation_id(content, name):
        return ('"' + name + '":"' + content.get("event").get("commonEventHeader").get("sourceName") + '",') if "sourceName" in content["event"]["commonEventHeader"] else ""

    @staticmethod
    def extract_correlation_id_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("commonEventHeader").get("sourceName") + '",' if "sourceName" in content["event"]["commonEventHeader"] else '",')

    @staticmethod
    def extract_serial_number(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("serialNumber") + '",') if "serialNumber" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_serial_number_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("serialNumber") + '",' if "serialNumber" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_vendor_name(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("vendorName") + '",') if "vendorName" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_vendor_name_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("vendorName") + '",' if "vendorName" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_model_number(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("modelNumber") + '",') if "modelNumber" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_model_number_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("modelNumber") + '",' if "modelNumber" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def extract_unit_type(content, name):
        return ('"' + name + '":"' + content.get("event").get("pnfRegistrationFields").get("unitType") + '",') if "unitType" in content["event"]["pnfRegistrationFields"] else ""

    @staticmethod
    def extract_unit_type_value(content, name):
        return '"' + name + '":"' + (content.get("event").get("pnfRegistrationFields").get("unitType") + '",' if "unitType" in content["event"]["pnfRegistrationFields"] else '",')

    @staticmethod
    def create_pnf_name(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("sourceName")
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


    # def create_invalid_notification(self, json_file):
    #     invalidate_input = self.create_pnf_ready_notification_from_ves(json_file).replace("\":", "\": ") \
    #         .replace("ipaddress-v4-oam", "oamV4IpAddress").replace("ipaddress-v6-oam","oamV6IpAddress").replace("}",'')
    #     invalidate_input__and_add_additional_fields = invalidate_input + ',"nfNamingCode": ""' + "," + '"softwareVersion": ""' +"\\n"
    #     return invalidate_input__and_add_additional_fields
