import os

RAVEN_DSN_URL = "https://s3.amazonaws.com/installer.scalr.com/logging/raven-dsn.txt"
RAVEN_DSN_CACHE_FILE = os.path.expanduser("~/.scalr-installer-logging-token")
LOGGING_FORMAT = "[%(asctime)s:%(levelname)s] [%(filename)s:%(lineno)s] [%(name)s] %(message)s"
