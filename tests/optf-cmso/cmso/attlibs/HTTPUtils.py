import urllib
from selenium import webdriver 
import base64

class HTTPUtils:
    """HTTPUtils is common resource for simple http helper keywords."""
    
    def url_encode_string(self, barestring):
        """URL Encode String takes in a string and converts into 'percent-encoded' string"""
        return urllib.quote_plus(barestring)
    
    def ff_profile(self):
        fp =webdriver.FirefoxProfile()
        fp.set_preference("dom.max_script_run_time",120)
        fp.update_preferences()
        return fp.path 
    
    def b64_encode(self, instring):
        "" 
        return base64.b64encode(instring)

