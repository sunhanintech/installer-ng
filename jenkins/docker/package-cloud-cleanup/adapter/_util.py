# coding:utf-8
import re
import itertools

from ._constant import HIGHEST_CHAR, LOWEST_CHAR


def get_version_tuple(version, iteration):
    v_list = []

    def str_processor(s):
        if not s.endswith('~'):
            s += HIGHEST_CHAR
        return s.replace('~', LOWEST_CHAR)

    for processor, matcher in itertools.cycle([
        (str_processor, re.compile('^(\D*)(.*)$')),
        (int, re.compile('^(\d*)(.*)$'))
    ]):

        if not version:
            break

        bit, version = matcher.match(version).groups()

        if bit:
            v_list.append(processor(bit))

    v_list.append(iteration)
    return tuple(v_list)

