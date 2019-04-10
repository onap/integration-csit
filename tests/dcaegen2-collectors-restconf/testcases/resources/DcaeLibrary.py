from robot.api import logger
import time

class DcaeLibrary(object):
    
    def __init__(self):
        pass

    @staticmethod
    def init_rcc():
        logger.console("RestConf collector init and cleanup are done")
        return "true"

    @staticmethod
    def teardown_rcc():
        logger.console("RestConf collector teardown done")
        return "true"

if __name__ == '__main__':
    time.sleep(100000)
