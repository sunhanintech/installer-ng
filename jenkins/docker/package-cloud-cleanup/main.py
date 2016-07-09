#coding:utf-8
import os
import re
import sys
import json
import itertools
import posixpath
import logging

import requests
from StringIO import StringIO
from requests.auth import HTTPBasicAuth

from debian import deb822, debfile
from repodataParser.RepoParser import Parser
from adapter._constant import API_URL
from adapter.deb import DebRepoAdapter
from adapter.rpm import RpmRepoAdapter



def main(config):
    has_erred = False

    api_session = requests.Session()
    api_session.auth = HTTPBasicAuth(config["api_token"], "")


    for repo in config["repositories"]:
        client_session = requests.Session()
        read_token = repo.get("read_token")
        if read_token is not None:
            client_session.auth = HTTPBasicAuth(read_token, "")

        kwargs = {
            "repo": repo["name"],
            "api_session": api_session,
            "client_session": client_session,
            "user": config["user"],
            "packages_to_clean": config["packages_to_clean"],
            "versions_to_keep": config["versions_to_keep"],
        }

        for adapter in [DebRepoAdapter(**kwargs), RpmRepoAdapter(**kwargs)]:
            has_erred |= adapter.clean()

    return 1 if has_erred else 0

def _pre_main():
    import logging
    logging.basicConfig(level=logging.DEBUG, format="%(levelname)s %(asctime)s %(name)s %(message)s")
    logging.getLogger('requests').setLevel(logging.WARNING)

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("config")
    ns = parser.parse_args()

    with open(ns.config) as f:
        config = json.load(f)

    sys.exit(main(config))


if __name__ == "__main__":
    _pre_main()
