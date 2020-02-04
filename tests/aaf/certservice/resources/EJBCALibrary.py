
import os
import subprocess
import time

from robot.api import logger


class EJBCALibrary(object):

    def __init__(self):
        pass



    @staticmethod
    def setup_EJBCA():
        ws = os.environ['WORKSPACE']
        script2run = ws + "/tests/aaf/certservice/resources/ejbcaSetup.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call([script2run, ws])
        time.sleep(5)
        return

    @staticmethod
    def shutdown_EJBCA():
        ws = os.environ['WORKSPACE']
        script2run = ws + "/tests/aaf/certservice/resources/ejbcaShutdown.sh"
        logger.info("Running script: " + script2run)
        logger.console("Running script: " + script2run)
        subprocess.call([script2run, ws])
        time.sleep(5)
        return








