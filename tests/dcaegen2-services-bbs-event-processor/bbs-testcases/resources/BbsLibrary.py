import json

import docker
import time
from docker.utils.json_stream import json_stream
from collections import OrderedDict


class BbsLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def check_for_log(search_for):
        client = docker.from_env()
        container = client.containers.get('bbs')

        alog = container.logs(stream=False, tail=1000)
        try:
            alog = alog.decode('utf-8').strip()
        except AttributeError:
            pass

        found = alog.find(search_for)
        if found != -1:
            return True
        else:
            return False

    @staticmethod
    def create_pnf_name_from_auth(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")
        return correlation_id

    @staticmethod
    def get_invalid_auth_elements(json_file):
        """
        Get the correlationId, oldState, newState, stateInterface, macAddress, swVersion elements
        from the invalid message and place the elements into a JSON object (string) as fields for comparision
        """
        eventString = json.loads(json_file)[0]
        json_to_python = json.loads(eventString.replace("\\", ""))
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")
        oldState = json_to_python.get("event").get("stateChangeFields").get("oldState")
        newState = json_to_python.get("event").get("stateChangeFields").get("newState")
        stateInterface = json_to_python.get("event").get("stateChangeFields").get("stateInterface")
        macAddress = json_to_python.get("event").get("stateChangeFields").get("additionalFields").get("macAddress")
        swVersion = json_to_python.get("event").get("stateChangeFields").get("additionalFields").get("swVersion")
        if swVersion is None:
            swVersion = ""
        
        inv_fields = OrderedDict()

        #inv_fields = dict()
        inv_fields['correlationId'] = correlation_id
        inv_fields['oldState'] = oldState
        inv_fields['newState'] = newState
        inv_fields['stateInterface'] = stateInterface
        inv_fields['macAddress'] = macAddress
        inv_fields['swVersion'] = swVersion
        
        # Transform the dictionary to JSON string
        json_str = json.dumps(inv_fields)
        
        # Need to remove spaces between elements
        json_str = json_str.replace(', ', ',')
        return json_str

    @staticmethod
    def get_invalid_update_elements(json_file):
        """
        Get the correlationId, attachment-point, remote-id, cvlan, svlan, elements
        from the invalid message and place the elements into a JSON object (string) as fields for comparision
        """
        eventString = json.loads(json_file)[0]
        json_to_python = json.loads(eventString.replace("\\", ""))
        correlation_id = json_to_python.get("correlationId")
        attachmentPoint = json_to_python.get("additionalFields").get("attachment-point")
        remoteId = json_to_python.get("additionalFields").get("remote-id")
        cvlan = json_to_python.get("additionalFields").get("cvlan")
        svlan = json_to_python.get("additionalFields").get("svlan")
        
        inv_fields = OrderedDict()
        #inv_fields = dict()
        inv_fields['correlationId'] = correlation_id
        inv_fields['attachment-point'] = attachmentPoint
        inv_fields['remote-id'] = remoteId
        inv_fields['cvlan'] = cvlan
        inv_fields['svlan'] = svlan
        
        # Transform the dictionary to JSON string
        json_str = json.dumps(inv_fields)
        
        # Need to remove spaces between elements
        json_str = json_str.replace(', ', ',')
        return json_str

    @staticmethod
    def compare_policy(dmaap_policy, json_policy):
        resp = False
        try:
            python_policy = json.loads(json_policy).pop()
        except:
            python_policy = ""
        
        try:
            python_dmaap_policy = json.loads(dmaap_policy)
        except:
            python_dmaap_policy = ""

        try:
            d_policy = python_dmaap_policy[0].get("policyName")
        except:
            d_policy = ""

        try:
            j_policy = python_policy.get("policyName")
        except:
            return "False"
        
        resp = "False"
        if (d_policy == j_policy):
            resp = "True"
        return resp

    @staticmethod
    def create_pnf_name_from_update(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("correlationId")
        return correlation_id

    @staticmethod
    def ensure_container_is_running(name):
        
        client = docker.from_env()

        if not BbsLibrary.is_in_status(client, name, "running"):
            print ("starting container", name)
            container = client.containers.get(name)
            container.start()
            BbsLibrary.wait_for_status(client, name, "running")

        BbsLibrary.print_status(client)

    @staticmethod
    def ensure_container_is_exited(name):

        client = docker.from_env()

        if not BbsLibrary.is_in_status(client, name, "exited"):
            print ("stopping container", name)
            container = client.containers.get(name)
            container.stop()
            BbsLibrary.wait_for_status(client, name, "exited")

        BbsLibrary.print_status(client)

    @staticmethod
    def print_status(client):
        print("containers status")
        for c in client.containers.list(all=True):
            print(c.name, "   ", c.status)

    @staticmethod
    def wait_for_status(client, name, status):
        while not BbsLibrary.is_in_status(client, name, status):
            print ("waiting for container: ", name, "to be in status: ", status)
            time.sleep(3)

    @staticmethod
    def is_in_status(client, name, status):
        return len(client.containers.list(all=True, filters={"name": "^/"+name+"$", "status": status})) == 1

