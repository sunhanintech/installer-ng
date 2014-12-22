#!/usr/bin/env python
# Helper script that outputs bash code to load a parsed version string.
from __future__ import print_function

import re
import sys

def print_stderr(*args, **kwargs):
    kwargs["file"] = sys.stderr
    print(*args, **kwargs)


VERSION_REGEX = re.compile(r"""
^                   #
(?P<major>\d+)      #
\.                  #
(?P<minor>\d+)      #
\.                  #
(?P<patch>\d+)      #
(?P<special_sep>-)? #
(?P<special>[a-b])? #
(?P<index_sep>\.)?  #
(?P<index>\d+)?     #
$                   #
""", re.VERBOSE)


def validate_version(version):
    """
    Validates that the version passed satisfies us.
    Returns None instead. Outputs info to stderr.

    >>> validate_version("1.1.1")
    {'index': None, 'major': '1', 'patch': '1', 'special': None, 'minor': '1'}

    >>> validate_version("10.20.30-a.40")
    {'index': '40', 'major': '10', 'patch': '30', 'special': 'a', 'minor': '20'}

    >>> validate_version("1.1")         # Not enough elements
    >>> validate_version("1.1.1-")      # Separator is alone
    >>> validate_version("1.1.1a.1")    # Special without separator
    >>> validate_version("1.1.1-a")     # Special without index
    >>> validate_version("1.1.1-a.")    # Separator is alone
    >>> validate_version("1.1.1-a1")    # Index without separator
    >>> validate_version("1.1.1-c.1")   # Special too high
    >>> validate_version("1.1.1.")      # Wrong separator
    >>> validate_version("1.1.1.1")     # Index without special
    """
    matched = VERSION_REGEX.match(version)
    if matched is None:
        print_stderr("Version '{0}' does not match version regex".format(version))
        return

    # Format is syntactically valid
    version_dict = matched.groupdict()

    # Check dependents
    dependencies = [("special_sep", "special"), ("special", "special_sep"), ("index_sep", "index"), ("index", "index_sep"), ("index", "special"), ("special", "index")]
    for dependent, dependency in dependencies:
        if version_dict[dependent] and not version_dict[dependency]:
            print_stderr("Version '{0}' is invalid: '{1}' is defined but not '{2}'".format(version, dependent, dependency))
            return None

    # Remove noise
    for noise in ["special_sep", "index_sep"]:
        del version_dict[noise]

    return version_dict


def shell_load_version(version_dict):
    version_dict["final"] = ".".join([version_dict[k] for k in ["major", "minor", "patch"]])
    version_dict["python"] = version_dict["final"] + "".join([v for v in [version_dict[k] for k in ["special", "index"]] if v is not None])
    for k, v in version_dict.items():
        print("VERSION_{0}='{1}'".format(k.upper(), v if v else ""))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./version_helper.py [version|--test]")
        sys.exit(-1)

    arg = sys.argv[1]

    if arg == "--test":
        import doctest
        sys.stderr = open('/dev/null', 'w')  # Silence output
        doctest.testmod()
    else:
        version = validate_version(arg)
        if version is None:
            print_stderr("Version is invalid -- exiting")
            print("exit 1")  # This controls the shell, it'll be eval'ed
            sys.exit(1)
        shell_load_version(version)

