
import os
import subprocess
import time

from robot.api import logger


class CertsLibrary(object):

    def __init__(self):
        pass



    @staticmethod
    def generate_certs():
        ws = os.environ['WORKSPACE']
        script2run = ws + "/tests/dcaegen2/testcases/resources/gen-certs.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call([script2run, ws])
        time.sleep(5)
        return

    @staticmethod
    def remove_certs():
        ws = os.environ['WORKSPACE']
        script2run = ws + "/tests/dcaegen2/testcases/resources/rm-certs.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call([script2run, ws])
        time.sleep(5)
        return








