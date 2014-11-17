#!/usr/bin/env python
import os
import sys

import setuptools

PROJECT_DIR = "scalr_manage"
EXCLUDE_FROM_PACKAGES = []

here = os.path.dirname(os.path.abspath(__file__))

with open(os.path.join(here, PROJECT_DIR, "version.py")) as f:
    code = compile(f.read(), "version.py", "exec")
    exec(code)

dependencies = ["requests", "setuptools", "jinja2"]
if sys.version_info < (2, 7, 0):
    dependencies.append("argparse")

setuptools.setup(
    name="scalr-manage",
    version=__version__,
    packages=setuptools.find_packages(),
    include_package_data=True,
    zip_safe=False,
    license="Apache Software License 2.0",
    author="Thomas Orozco",
    author_email="thomas@scalr.com",
    description="Management CLI for the Scalr installer",
    entry_points={
        "console_scripts": [
            "scalr-manage = scalr_manage.cli:main"
        ]
    },
    install_requires=dependencies,
    #setup_requires=["nose", "setuptools_git"],
    tests_require=["nose", "tox", "testfixtures"],
    url="https://github.com/scalr/installer-ng"
)
