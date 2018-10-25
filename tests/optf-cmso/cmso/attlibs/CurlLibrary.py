from curl import Curl

class CurlLibrary:
   

    def get_zip(self, url, filename):
        fp = open(filename, "wb")
        c = Curl()
        c.get(url, )
        c.set_option(c.WRITEDATA, fp)
        c.perform()
        c.close()
        fp.close()