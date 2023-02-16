import base64


def parse_response(response):
    cert_chain = response["certificateChain"]
    encoded_bytes = base64.b64encode(bytes("".join(cert_chain), 'utf-8'))
    base64_str = encoded_bytes.decode('utf-8')
    return base64_str.replace("\n", "").strip()
