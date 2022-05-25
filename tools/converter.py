#!/usr/bin/python3

import argparse
import sys
from pathlib import Path
from collections import namedtuple
import multiprocessing as mp
from queue import Empty
from uuid import UUID
import tempfile
import numpy
import pyslow5
import pod5_format

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)


def get_all_pod5(input):
    file = pod5_format.open_combined_file(input)
    for read in file.reads():
        # do stuff



def main():

    parser = MyParser(description="Converter - SLOW5 <-> POD5 converter",
    epilog="Citation:...",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    subcommand = parser.add_subparsers(help='subcommand --help for help messages', dest="command")

    # POD5 to SLOW5
    p2s = subcommand.add_parser('p2s', help='POD5 -> SLOW5',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p2s.add_argument("input", type=Path)
    p2s.add_argument("output", type=Path)

    # SLOW5 to POD5
    s2p = subcommand.add_parser('s2p', help='SLOW5 -> POD5',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    s2p.add_argument("input", type=Path)
    s2p.add_argument("output", type=Path)

    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
