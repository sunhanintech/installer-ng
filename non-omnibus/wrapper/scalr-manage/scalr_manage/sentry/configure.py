# coding:utf-8
import os
import platform
import logging

from raven import Client
from raven.conf import setup_logging
from raven.handlers.logging import SentryHandler

from scalr_manage.sentry.constant import RAVEN_DSN_ENV_VAR
from scalr_manage.version import __version__


logger = logging.getLogger(__name__)


def maybe_enable_remote_logging():
    """
    Enable logging to sentry if RAVEN_DSN_ENV_VAR is set to a DSN.
    """
    raven_dsn = os.environ.get(RAVEN_DSN_ENV_VAR)
    if raven_dsn:
        tags = dict(zip(
            ["os_name", "os_version", "os_codename"],
            (item.lower() for item in platform.linux_distribution(full_distribution_name=False))
        ))
        tags["manage_version"] = __version__
        setup_logging(SentryHandler(Client(raven_dsn, tags=tags), level=logging.ERROR))
        logger.debug("Remote logging was enabled")
