# coding:utf-8
import json
import logging

import jinja2

from scalr_manage.library.base import Target


logger = logging.getLogger(__name__)


class DocumentTarget(Target):
    name = "document"
    help = "Document the Scalr install on this host"

    def __call__(self, args, ui, tokgen):
        self._check_configuration(args)

        with open(args.configuration) as f:
            attrs = json.load(f)

        env = jinja2.Environment(autoescape=False, loader=jinja2.PackageLoader("scalr_manage", "templates"))
        tpl = env.get_template("success.mkd")

        # We eliminate duplicate lines so that we don't end up with plenty of blank lines
        last_line = None
        for line in tpl.render(**{"attrs": attrs, "args": args}).split("\n"):
            if line != last_line:
                ui.print_fn(line)
            last_line = line
