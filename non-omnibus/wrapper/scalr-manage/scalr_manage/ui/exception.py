# coding:utf-8
class InvalidInput(Exception):
    def __init__(self, reason="Unknown error"):
        self.reason = reason
