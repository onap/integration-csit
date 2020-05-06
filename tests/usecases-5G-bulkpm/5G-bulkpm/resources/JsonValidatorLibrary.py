# -*- coding: utf-8 -*-

import logging

from jsonschema import validate, ValidationError, SchemaError
from simplejson import load


class JsonValidatorLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def validate(schema_path, json_path):
        logging.info("Schema path: " + schema_path)
        logging.info("JSON path: " + json_path)
        schema = None
        data = None
        try:
            schema = load(open(schema_path, 'r'))
            data = load(open(json_path, 'r'))
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
