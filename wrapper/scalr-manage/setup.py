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

def fullsplit(path, result=None):
    """
    Split a pathname into components (the opposite of os.path.join)
    in a platform-neutral way.
    """
    if result is None:
        result = []
    head, tail = os.path.split(path)
    if head == '':
        return [tail] + result
    if head == path:
        return result
    return fullsplit(head, [tail] + result)



def is_package(package_name):
    for pkg in EXCLUDE_FROM_PACKAGES:
        if package_name.startswith(pkg):
            return False
    return True


# Compile the list of packages available, because distutils doesn't have
# an easy way to do this.
packages, package_data = [], {}

root_dir = os.path.dirname(__file__)
if root_dir != '':
    os.chdir(root_dir)
django_dir = 'scalr_manage'

for dirpath, dirnames, filenames in os.walk(django_dir):
    # Ignore PEP 3147 cache dirs and those whose names start with '.'
    dirnames[:] = [d for d in dirnames if not d.startswith('.') and d != '__pycache__']
    parts = fullsplit(dirpath)
    package_name = '.'.join(parts)
    if '__init__.py' in filenames and is_package(package_name):
        packages.append(package_name)
    elif filenames:
        relative_path = []
        while '.'.join(parts) not in packages:
            relative_path.append(parts.pop())
        relative_path.reverse()
        path = os.path.join(*relative_path)
        package_files = package_data.setdefault('.'.join(parts), [])
        package_files.extend([os.path.join(path, f) for f in filenames])

dependencies = ["requests>=1.0.0", "setuptools", "jinja2", "raven>=5.1.1,<6.0.0"]
if sys.version_info < (2, 7, 0):
    dependencies.append("argparse")

setuptools.setup(
    name="scalr-manage",
    version=__version__,
    packages=packages,
    package_data=package_data,
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
    tests_require=["nose", "tox"],
    url="https://github.com/scalr/installer-ng"
)
