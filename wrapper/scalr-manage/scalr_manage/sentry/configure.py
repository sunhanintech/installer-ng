# coding:utf-8
import os
import logging

from raven.handlers.logging import SentryHandler
from raven.conf import setup_logging

from scalr_manage.sentry.constant import RAVEN_DSN_ENV_VAR


logger = logging.getLogger(__name__)


def maybe_enable_remote_logging():
    """
    Enable logging to sentry if RAVEN_DSN_ENV_VAR is set to a DSN.
    """
    raven_dsn = os.environ.get(RAVEN_DSN_ENV_VAR)
    if raven_dsn:
        logger.debug("Remote logging was enabled")
        setup_logging(SentryHandler(raven_dsn, level=logging.ERROR))
