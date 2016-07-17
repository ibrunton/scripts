#!/usr/bin/env python

import sys
import re
from os.path import expanduser

def sbocheck(updatesfile):
    installedfile = "~/Dropbox/docs/slackbuilds-14.2"
    installedfile = expanduser(installedfile)

    installed = {}
    fp = open(installedfile)
    for line in fp:
        if re.match('#', line) or re.match("^$", line):
            continue
        packages = re.split(' ', line)
        for p in packages:
            np = re.sub(':', '', p)
            np = re.sub('\n', '', np)
            installed[np] = 1

    fp.close()

    updatesfile = expanduser(updatesfile)
    fp = open(updatesfile)
    for line in fp:
        line = re.sub("\n", '', line)
        (package, update) = re.split(' ', line, maxsplit=1)
        if re.match('Update|Fix|Change', update):
            (category, name) = re.split('/', package)
            name = re.sub(':', '', name)
            if name in installed:
                print(line)

    fp.close()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        ufile = "~/Dropbox/docs/sbo_updates"
    else:
        ufile = sys.argv[1]

    sbocheck(ufile)
