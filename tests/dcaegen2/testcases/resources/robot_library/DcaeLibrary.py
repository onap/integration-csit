'''
Created on Aug 18, 2017

@author: sw6830
'''
from robot.api import logger
import uuid
import time
import datetime
import json
import os
import platform
import subprocess
import paramiko


class DcaeLibrary(object):

    def __init__(self):
        pass
    
    @staticmethod
    def enable_vesc_with_certBasicAuth():
        global client
        if 'Windows' in platform.system():
            try:
                client = paramiko.SSHClient()
                client.load_system_host_keys()
                client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                
                client.connect(os.environ['CSIT_IP'], port=22, username=os.environ['CSIT_USER'], password=os.environ['CSIT_PD'])
                stdin, stdout, stderr = client.exec_command('%{WORKSPACE}/tests/dcaegen2/testcases/resources/vesc_enable_https_auth.sh')
                logger.console(stdout.read())    
            finally:
                client.close()
            return
        ws = os.environ['WORKSPACE']
        script2run = ws + "/tests/dcaegen2/testcases/resources/vesc_enable_https_auth.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call(script2run)
        time.sleep(5)
        return

    @staticmethod
    def is_json_empty(resp):
        logger.info("Enter is_json_empty: resp.text: " + resp.text)
        if resp.text is None or len(resp.text) < 2:
            return 'True'
        return 'False'
    
    @staticmethod
    def generate_uuid():
        """generate a uuid"""
        return uuid.uuid4()
    
    @staticmethod
    def get_json_value_list(jsonstr, keyval):
        logger.info("Enter Get_Json_Key_Value_List")
        if jsonstr is None or len(jsonstr) < 2:
            logger.info("No Json data found")
            return []
        try:
            data = json.loads(jsonstr)   
            nodelist = []
            for item in data:
                nodelist.append(item[keyval])
            return nodelist
        except Exception as e:
            logger.info("Json data parsing fails")
            print str(e)
            return []
        
    @staticmethod
    def generate_millitimestamp_uuid():
        """generate a millisecond timestamp uuid"""
        then = datetime.datetime.now()
        return int(time.mktime(then.timetuple())*1e3 + then.microsecond/1e3)
    
    @staticmethod
    def test():
        import json
        from pprint import pprint

        with open('robot/assets/dcae/ves_volte_single_fault_event.json') as data_file:    
            data = json.load(data_file)

        data['event']['commonEventHeader']['version'] = '5.0'
        pprint(data)


if __name__ == '__main__':

    lib = DcaeLibrary()
    lib.enable_vesc_https_auth()
    
    ret = lib.setup_dmaap_server()
    print ret
    time.sleep(100000)
