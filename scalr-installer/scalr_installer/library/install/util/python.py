# coding:utf-8
import os
import shutil
import contextlib
import subprocess
import tempfile


@contextlib.contextmanager
def umask(mask):
    old_mask = os.umask(mask)
    yield
    os.umask(old_mask)


@contextlib.contextmanager
def tmp_dir():
    dir = tempfile.mkdtemp()
    yield dir
    shutil.rmtree(dir)


@contextlib.contextmanager
def path(path):
    old_path = os.environ["PATH"]
    os.environ["PATH"] = path
    yield
    os.environ["PATH"] = old_path


# Python 2.6 support
def check_output(*popenargs, **kwargs):
    if "stdout" in kwargs:
        raise ValueError("stdout argument not allowed, it will be overridden.")
    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        err = subprocess.CalledProcessError(retcode, cmd)
        err.output = output
        raise err
    return output