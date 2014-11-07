# coding:utf-8
import string
import binascii


class RandomTokenGenerator(object):
    def __init__(self, random_source):
        self.random_source = random_source
        self._chars = string.letters + string.digits + "+="  # 64 divides 256

    def make_password(self, length):
        pw_chars = []
        for c in self.random_source(length):
            pw_chars.append(self._chars[ord(c) % len(self._chars)])
        return "".join(pw_chars)

    def make_id(self, installer_release):
        major, minor, patch = installer_release.split(".", 2)
        bits = ["i", major, "x", binascii.hexlify(self.random_source(4))]
        return "".join(bits)


