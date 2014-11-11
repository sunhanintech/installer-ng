# coding:utf-8

class MockInput(object):
    def __init__(self):
        self.inputs = []
        self.prompts = []

    def __call__(self, prompt):
        """ Return one of our test inputs, but check it's valid first."""
        self.prompts.append(prompt)
        s = self.inputs.pop(0)
        assert "\n" not in s
        return s


class MockOutput(object):
    def __init__(self):
        self.outputs = []

    def __call__(self, out):
        self.outputs.append(out)