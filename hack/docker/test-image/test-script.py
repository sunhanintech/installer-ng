#!/usr/bin/env python
import sys
import json
import datetime
import base64

import requests

from scalr_client import session


TEST_USER_NAME = "Test User"
TEST_USER_EMAIL = "test@scalr.com"
TEST_USER_PASSWORD = "testuserpass"


def make_test_user_password(n_entropy):
    with open('/dev/urandom') as f:
        return base64.b64encode(f.read(n_entropy))


if __name__ == "__main__":
    actions = sys.argv[1:]

    with open("/etc/scalr-server/scalr-server-secrets.json") as f:
        secrets = json.load(f)

    base_url = "http://{0}:{1}".format("scalr", "80")


    while 1:
        try:
            action = actions.pop(0)
        except IndexError:
            break

        if action == "ping":
            # Create a new user
            res = requests.get(base_url)
            res.raise_for_status()

        elif action == "create":
            admin_username = "admin"
            admin_password = secrets["app"]["admin_password"]

            adm_session = session.ScalrSession(base_url=base_url)
            adm_session.login(admin_username, admin_password)

            res = adm_session.create_account(TEST_USER_NAME, TEST_USER_EMAIL, TEST_USER_PASSWORD)
            test_user_id = res.json()["accountId"]

        elif action == "login":
            user_session = session.ScalrSession(base_url=base_url)
            user_session.login(TEST_USER_EMAIL, TEST_USER_PASSWORD)
            user_session.get_ec2_cloud_params().json()

        else:
            raise Exception("Unknown action: %s" % action)

        print "%s: success" % action

