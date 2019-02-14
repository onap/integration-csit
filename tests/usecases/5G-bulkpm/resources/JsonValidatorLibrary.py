# -*- coding: utf-8 -*-

import sys
import logging
from simplejson import load
from jsonschema import validate, ValidationError, SchemaError


class JsonValidatorLibrary(object):

    def __init__(self):
        pass

    def validate(self, schemaPath, jsonPath):
        logging.info("Schema path: " + schemaPath)
        logging.info("JSON path: " + jsonPath)
        schema = None
        data = None
        try:
            schema = load(open(schemaPath, 'r'))
            data = load(open(jsonPath, 'r'))
        except (IOError, ValueError, OSError) as e:
            logging.error(e.message)
            return 1

        try:
            validate(data, schema)
        except (ValidationError, SchemaError) as e:
            logging.error(e.message)
            return 1

        # logger.log("JSON validation successful")
        print("JSON validation successful")
        return 0

if __name__ == '__main__':
    lib = JsonValidatorLibrary()
    # sys.exit(JsonValidatorLibrary().validate(sys.argv[1], sys.argv[2]))
