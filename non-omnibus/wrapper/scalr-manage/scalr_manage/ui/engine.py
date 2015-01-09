# coding:utf-8
from __future__ import unicode_literals

import socket

from scalr_manage.ui.constant import OPENSSL_START_KEY_RE, OPENSSL_END_KEY_RE, OPENSSL_PROC_TYPE, OPENSSL_ENCRYPTED, \
    EMAIL_RE
from scalr_manage.ui.exception import InvalidInput
from scalr_manage.ui.util import format_symbol


class UserInput(object):
    def __init__(self, prompt_fn, print_fn):
        self.prompt_fn = prompt_fn
        self.print_fn = print_fn

    def prompt(self, q, error_msg="", coerce_fn=lambda x: x.strip()):
        while True:
            r = self.prompt_fn(q + "\n> ")
            try:
                ret = coerce_fn(r)
            except InvalidInput as e:
                self.print_fn("{0} ({1})".format(error_msg, e.reason))
            else:
                self.print_fn("")  # Newline
                return ret

    def prompt_ssh_key(self, q, error_msg="This is not a valid SSH private key"):
        key = ""

        while not key:
            first_line = self.prompt_fn(q + "\n>\n")
            if OPENSSL_START_KEY_RE.match(first_line) is None:
                self.print_fn("{0} (paste a PEM-formatted SSH private key; don't use another format, and don't use a path to a file)".format(error_msg))
                continue

            lines = [first_line]
            while 1:
                line = self.prompt_fn("")
                lines.append(line)

                if OPENSSL_END_KEY_RE.match(line) is not None:
                    lines.append("")  # Newline
                    key = "\n".join(lines)
                    break

                if line.startswith(OPENSSL_PROC_TYPE) and OPENSSL_ENCRYPTED in line:
                    # This will break out of the inner loop, and continue into the outer loop
                    # because we stil have (key == "").
                    self.print_fn("{0} (This is an encrypted SSH private key, those are not supported in the installer)".format(error_msg))
                    break

        return key

    def prompt_select_from_options(self, q, options, error_msg="This is not a valid choice"):
        opts_string = ", ".join(map(format_symbol, options))

        def coerce_fn(r):
            if r in options:
                return r
            raise InvalidInput("{0} is not one of {1}".
                               format(format_symbol(r), opts_string))

        return self.prompt("{0} [{1}]".format(q, opts_string), error_msg,
                           coerce_fn)

    def prompt_yes_no(self, q, error_msg="This is not a valid choice"):
        _yes_no_mapping = {"y":True, "n":False}
        ret = self.prompt_select_from_options(q, _yes_no_mapping.keys(), error_msg)
        return _yes_no_mapping[ret]

    def prompt_ipv4(self, q, error_msg="This is not a valid IP"):
        def coerce_fn(r):
            sym = format_symbol(r)

            try:
                socket.inet_aton(r)
            except socket.error:
                raise InvalidInput("{0} is not a valid IP address".format(sym))

            if len(r.split(".")) != 4:
                # Technically speaking, this would be a valid IPV4 address,
                # but it's most likely an error.
                raise InvalidInput("Please enter a full address")

            return r

        return self.prompt(q, error_msg, coerce_fn)

    def prompt_email(self, q, error_msg="This is not a valid email"):
        def coerce_fn(r):
            if not EMAIL_RE.match(r):
                raise InvalidInput("{0} is not a valid email address".format(format_symbol(r)))
            return r

        return self.prompt(q, error_msg, coerce_fn)

    def prompt_integer(self, q, error_msg="This is not a valid input"):
        def coerce_fn(r):
            try:
                return int(r)
            except ValueError:
                raise InvalidInput("{0} is not an integer".format(format_symbol(r)))
        return self.prompt(q, error_msg, coerce_fn)
