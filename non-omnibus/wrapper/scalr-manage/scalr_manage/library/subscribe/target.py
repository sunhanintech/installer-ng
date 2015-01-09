# coding:utf-8
import json
import logging

import requests

from scalr_manage.library.base import Target
from scalr_manage.library.subscribe import constant


logger = logging.getLogger(__name__)


class SubscribeTarget(Target):
    name = "subscribe"
    help = "Subscribe to important Scalr notifications and security updates"

    def __call__(self, args, ui, tokgen):
        self._check_configuration(args)

        with open(args.configuration) as f:
            attrs = json.load(f)
            id = attrs.get("scalr", {}).get("id", "")

        signup = ui.prompt_yes_no("Would you like to be notified of Scalr security updates and critical bug "
                                  "fixes? Notifications are delivered by email.", "This isn't a valid choice")

        if not signup:
            return

        email = ui.prompt_email("Please enter your email address", "This is not a valid email")

        try:
            res = requests.post(constant.NOTIFICATION_FORM_URL, data={
                constant.NOTIFICATION_ATTR_EMAIL: email,
                constant.NOTIFICATION_ATTR_ID: id
            })
            res.raise_for_status()
        except requests.RequestException:
            logger.exception("Registration failed!")
            ui.print_fn("An error occurred registering your installation!")
        else:
            ui.print_fn("Registration successful!")
