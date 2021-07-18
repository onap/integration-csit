def parse_response(response):
  certChain = response["certificateChain"]
  return "".join(certChain).encode("base64").replace("\n", "").strip()
