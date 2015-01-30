#!/usr/bin/env python
import sys
import collections

from git import Repo

# We keep two of those in case there was an accident.
RETAIN_TAGS = 2


def clean_repo(path):
    repo = Repo(path)

    grouped_tags = collections.defaultdict(list)

    for tag in repo.tags:
        grouped_tags[tag.name.rsplit('-', 1)[0]].append(tag)

    for name, tags in grouped_tags.items():
        if len(tags) <= RETAIN_TAGS:
            continue

        print "Trimming {0} ({1} tags)".format(name, len(tags))
        tags.sort(key=lambda tag: tag.commit.authored_date, reverse=True)

        for tag_for_deletion in tags[RETAIN_TAGS:]:
            # First, check we're not messing anything up
            for retained_tag in tags[:RETAIN_TAGS]:
                assert tag_for_deletion.commit.authored_date < retained_tag.commit.authored_date
            # Then, delete!
            print "Removing tag: {0}".format(tag_for_deletion.name)
            repo.delete_tag(tag_for_deletion)
        print


if __name__ == "__main__":
    clean_repo(sys.argv[1])
