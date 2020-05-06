'''
Created on Aug 18, 2017

@author: sw6830
'''
import time
import uuid

from robot.api import logger


class xNFLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def create_header_from_string(dict_str):
        logger.info("Enter create_header_from_string: dictStr")
        return dict(u.split("=") for u in dict_str.split(","))

    @staticmethod
    def Generate_UUID(self):
        """generate a uuid"""
        return uuid.uuid4()


if __name__ == '__main__':
    lib = xNFLibrary()
    time.sleep(100000)
