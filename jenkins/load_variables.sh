#!/bin/bash

eval $(sudo szradm -q list-global-variables --format=json | python -c $'

import sys
import json

gvs = json.load(sys.stdin)

for key, value in gvs["variables"]["values"].iteritems():
  print "export {0}=\'{1}\';".format(key, value)

for key, value in gvs["variables"]["private_values"].iteritems():
  print "export {0}=\'{1}\';".format(key, value)

')
