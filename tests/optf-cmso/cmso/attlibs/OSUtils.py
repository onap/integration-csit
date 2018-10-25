from sys import platform

class OSUtils:
    """ Utilities useful for constructing OpenStack HEAT requests """

    def get_normalized_os(self):
        os = platform
        if platform == "linux" or platform == "linux2":
            os = 'linux64'
        elif platform == "darwin":
            os = 'mac64'
        elif platform == "win32":
            os = platform
        return os
