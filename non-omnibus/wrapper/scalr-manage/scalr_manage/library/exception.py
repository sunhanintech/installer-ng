class ConfigurationException(Exception):
    def __init__(self, path):
        self.path = path

class NoConfigurationException(ConfigurationException):
    pass


class InvalidConfigurationException(ConfigurationException):
    pass


class InstallerException(Exception):
    def __init__(self, log_file):
        self.log_file = log_file
