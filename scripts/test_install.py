import os
import unittest

import install


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


class IOTestCase(unittest.TestCase):
    def setUp(self):
        self.input = MockInput()
        self.output = MockOutput()
        self.io = install.UserInput(self.input, self.output)

    def test_prompt_logic(self):
        self.input.inputs.extend(["in1", "in2", "in3"])

        q = "QUERY?"
        err = "ERROR!"
        msg = "INVALID!"

        def coerce_fn(r):
            if r == "in3":
                return r
            raise install.InvalidInput(msg)

        self.io.prompt(q, err, coerce_fn)

        self.assertEqual(3, len(self.input.prompts))
        self.assertEqual(3, len(self.output.outputs))

        for prompt in self.input.prompts:
            self.assertIn(q, prompt)

        for output in self.output.outputs[:-1]:
            self.assertIn(err, output)
            self.assertIn(msg, output)

        self.assertEqual("", self.output.outputs[-1])

    def test_prompt_from_options(self):
        self.input.inputs.extend(["opt1", "opt2", "opt3"])

        ret = self.io.prompt_select_from_options("?", ["opt3", "opt4"], "!")
        self.assertEqual("opt3", ret)

    def test_prompt_yes_no(self):
        self.input.inputs.extend(["unrelated", "Y", "n"])
        ret = self.io.prompt_yes_no("?", "!")
        self.assertFalse(ret)

    def test_prompt_ipv4(self):
        self.input.inputs.extend(["0", "::1", "127.0.0.1"])
        ret = self.io.prompt_ipv4("?", "!")
        self.assertEqual("127.0.0.1", ret)

    def test_prompt_email(self):
        self.input.inputs.extend(["abc", "test@e@test.com", "a+b@my.test.com"])
        ret = self.io.prompt_email("?", "!")
        self.assertEqual("a+b@my.test.com", ret)

    def test_prompt_ssh_key(self):
        keys_path = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                                 "test_data")
        with open(os.path.join(keys_path, "test_encrypted_ssh_key")) as f:
            encrypted_key_parts = f.read().split("\n")

        with open(os.path.join(keys_path, "test_ssh_key")) as f:
            ok_key = f.read()
            ok_key_parts = ok_key.split("\n")

        self.input.inputs.extend(encrypted_key_parts)
        self.input.inputs.extend(ok_key_parts)

        ret = self.io.prompt_ssh_key("?", "!")

        self.assertEqual(ok_key, ret)



if __name__ == "__main__":
    unittest.main()
