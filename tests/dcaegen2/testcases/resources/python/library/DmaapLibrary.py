from Queue import Queue
try:
    from robot.api import logger
except ImportError:
    from ..test.robotmock import logger

import json
import threading
import time

import DcaeVariables
from ..dmaap import DMaaPServer
from ..dmaap.DMaaPQueue import DMaaPSQueue


class DmaapLibrary(object):

    dmaap_queue = None
    dmaap_server = None
    server_thread = None

    def __init__(self):
        pass

    @staticmethod
    def setup_dmaap_server(port_num=3904):
        try:
            DmaapLibrary.dmaap_queue = DMaaPSQueue(Queue())
            DmaapLibrary.dmaap_server = DMaaPServer.create_dmaap_server(DmaapLibrary.dmaap_queue, port=port_num)
            DmaapLibrary.server_thread = threading.Thread(name='DMAAP_HTTPServer',
                                                              target=DmaapLibrary.dmaap_server.serve_forever)
            DmaapLibrary.server_thread.start()
            logger.console("DMaaP Mockup Sever started")
            DcaeVariables.IsRobotRun = True
            time.sleep(2)
            return "true"
        except Exception as e:
            print (str(e))
            return "false"

    @staticmethod
    def shutdown_dmaap():
        if DmaapLibrary.dmaap_server is not None:
            DmaapLibrary.dmaap_server.shutdown()
            logger.console("DMaaP Server shut down")
            time.sleep(3)
            return "true"
        else:
            return "false"

    @staticmethod
    def cleanup_ves_events():
        if DmaapLibrary.server_thread is not None:
            DmaapLibrary.dmaap_queue.clean_up_event()
            logger.console("DMaaP event queue is cleaned up")
            return "true"
        logger.console("DMaaP server not started yet")
        return "false"

    @staticmethod
    def dmaap_message_receive_on_topic(evtobj, topic):

        evt_str = DmaapLibrary.dmaap_queue.deque_event()
        while evt_str != None:
            if evtobj in evt_str and topic in evt_str:
                logger.info("DMaaP Receive Expected Publish Event:\n" + evt_str)
                logger.info("On Expected Topic:\n" + topic)
                return 'true'
            evt_str = DmaapLibrary.dmaap_queue.deque_event()
        return 'false'

    @staticmethod
    def dmaap_message_receive(evtobj, action='contain'):

        evt_str = DmaapLibrary.dmaap_queue.deque_event()
        while evt_str != None:
            if action == 'contain':
                if evtobj in evt_str:
                    logger.info("DMaaP Receive Expected Publish Event:\n" + evt_str)
                    return 'true'
            if action == 'sizematch':
                if len(evtobj) == len(evt_str):
                    return 'true'
            if action == 'dictmatch':
                evt_dict = json.loads(evt_str)
                if cmp(evtobj, evt_dict) == 0:
                    return 'true'
            evt_str = DmaapLibrary.dmaap_queue.deque_event()
        return 'false'
