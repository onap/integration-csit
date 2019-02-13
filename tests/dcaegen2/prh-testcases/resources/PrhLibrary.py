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
        for line in container.logs(stream=True):
            if search_for in line.strip():
                return True
        else:
            return False

    @staticmethod
    def create_pnf_ready_notification_from_ves(json_file):
        json_to_python = json.loads(json_file)
        ipv4 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV4IpAddress")
        ipv6 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") if "oamV6IpAddress" in json_to_python["event"]["pnfRegistrationFields"] else ""
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")

        serial_number = json_to_python.get("event").get("pnfRegistrationFields").get("serialNumber") if "serialNumber" in json_to_python["event"]["pnfRegistrationFields"] else ""
        vendor_name = json_to_python.get("event").get("pnfRegistrationFields").get("vendorName") if "vendorName" in json_to_python["event"]["pnfRegistrationFields"] else ""
        model_number = json_to_python.get("event").get("pnfRegistrationFields").get("modelNumber") if "modelNumber" in json_to_python["event"]["pnfRegistrationFields"] else ""
        unit_type = json_to_python.get("event").get("pnfRegistrationFields").get("unitType") if "unitType" in json_to_python["event"]["pnfRegistrationFields"] else ""

        str_json = '{"correlationId":"' + correlation_id + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '","serialNumber":"' + serial_number + '","vendorName":"' + vendor_name  + '","modelNumber":"' + model_number + '","unitType":"' + unit_type + '"}'
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

    @staticmethod
    def create_pnf_ready_notification_as_pnf_ready(json_file):
        json_to_python = json.loads(json_file)
        ipv4 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV4IpAddress")
        ipv6 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") if "oamV6IpAddress" in json_to_python["event"]["pnfRegistrationFields"] else ""
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")

        serial_number = json_to_python.get("event").get("pnfRegistrationFields").get("serialNumber") if "serialNumber" in json_to_python["event"]["pnfRegistrationFields"] else ""
        vendor_name = json_to_python.get("event").get("pnfRegistrationFields").get("vendorName") if "vendorName" in json_to_python["event"]["pnfRegistrationFields"] else ""
        model_number = json_to_python.get("event").get("pnfRegistrationFields").get("modelNumber") if "modelNumber" in json_to_python["event"]["pnfRegistrationFields"] else ""
        unit_type = json_to_python.get("event").get("pnfRegistrationFields").get("unitType") if "unitType" in json_to_python["event"]["pnfRegistrationFields"] else ""
        nf_role  = json_to_python.get("event").get("commonEventHeader").get("nfNamingCode") if "nfNamingCode" in json_to_python["event"]["commonEventHeader"] else ""

        str_json = '{"correlationId":"' + correlation_id + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '","serial-number":"' + serial_number + '","equip-vendor":"' + vendor_name  + '","equip-model":"' + model_number + '","equip-type":"' + unit_type + '","nf-role":"' + nf_role + '","sw-version":""}'
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

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


    def create_invalid_notification(self, json_file):
        return self.create_pnf_ready_notification_from_ves(json_file).replace("\":", "\": ")\
            .replace("ipaddress-v4-oam", "oamV4IpAddress").replace("ipaddress-v6-oam", "oamV6IpAddress") \
            .replace("serial-number", "serialNumber").replace("equip-vendor", "vendorName") \
            .replace("equip-model", "modelNumber").replace("equip-type", "unitType") \
            .replace("nf-role", "nfNamingCode").replace("}", "\\n}")