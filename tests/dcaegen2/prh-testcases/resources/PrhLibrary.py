import json

class PrhLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def create_invalid_notification(json_file):
        output =  {}
        input = json.loads(json_file)[0]

        output["correlationId"] = PrhLibrary.__extract_correlation_id_value(input)
        output["oamV4IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV4IpAddress")
        output["oamV6IpAddress"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "oamV6IpAddress")
        output["serialNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "serialNumber")
        output["vendorName"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "vendorName")
        output["modelNumber"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "modelNumber")
        output["unitType"] = PrhLibrary.__extract_value_from_pnfRegistrationFields(input, "unitType")
        output['nfNamingCode'] = ''
        output['softwareVersion'] = ''

        additional_fields = PrhLibrary.__get_additional_fields_as_key_value_pairs(input)
        if len(additional_fields) > 0:
            output["additionalFields"] = additional_fields

        return json.dumps(output)

    @staticmethod
    def __get_additional_fields_as_key_value_pairs(content):
        return content.get("event").get("pnfRegistrationFields").get(
            "additionalFields") if "additionalFields" in content["event"]["pnfRegistrationFields"] else []

    @staticmethod
    def __extract_value_from_pnfRegistrationFields(content, key):
        return content["event"]["pnfRegistrationFields"][key] if key in content["event"]["pnfRegistrationFields"] else ''

    @staticmethod
    def __extract_correlation_id_value(content):
        return content["event"]["commonEventHeader"]["sourceName"] if "sourceName" in content["event"]["commonEventHeader"] else ''
