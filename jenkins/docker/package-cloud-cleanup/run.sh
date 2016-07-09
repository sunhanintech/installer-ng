#!/bin/bash

cd $(dirname "$0")

pip install -r requirements.txt
python main.py /config/${CONFIG_FILE}
