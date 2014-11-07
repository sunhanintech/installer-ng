# coding:utf-8
import shutil

import requests


def download(url, dest):
    res = requests.get(url, stream=True)
    res.raise_for_status()
    with open(dest, "wb") as f:
        res.raw.decode_content = True
        shutil.copyfileobj(res.raw, f)

