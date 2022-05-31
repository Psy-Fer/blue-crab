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


def dump_run_info(run_info, indent=0):
    indent_str = " " * indent
    for name, value in run_info._asdict().items():
        if isinstance(value, list):
            print(f"{indent_str}  {name}")
            for k, v in value:
                print(f"{indent_str}    {k}: {v}")
        else:
            print(f"{indent_str}  {name}: {value}")



def get_all_slow5(input):
    '''
    yield slow5 reads using input path
    '''
    s5 = pyslow5.Open(input, 'r')
    for read in s5.seq_reads_multi(threads=threads, batch_size=1000, aux='all'):
        # do stuff
        slow5_read = {
            "read_id": read.read_id,
            "read_group": read.read_group,
            "digitisation": read.digitisation,
            "offset": read.offset,
            "range": read.range,
            "sampling_rate": read.sampling_rate,
            "len_raw_signal": read.len_raw_signal,
            "signal": read.signal,
            "channel_number": read.channel_number,
            "median_before": read.median_before,
            "read_number": read.read_number,
            "start_mux": read.start_mux,
            "start_time": read.start_time,
            }
        print("slow5_read:")
        print(slow5_read)
        yield slow5_read



def get_all_pod5(input):
    '''
    yield slow5 reads using input path
    '''
    file = pod5_format.open_combined_file(input)
    print(dir(file))
    print(vars(file))
    for read in file.reads():
        # do stuff
        print(dir(read))
        print(vars(read))
        print(read.calibration)
        sample_count = read.sample_count
        byte_count = read.byte_count
        pore_data = read.pore
        end_reason_data = read.end_reason

        pod5_read = {
            "read_id": read.read_id,
            "channel": pore_data.channel,
            "well": pore_data.well,
            "pore_type": pore_data.pore_type,
            "read_number": read.read_number,
            "start_sample": read.start_sample,
            "end_reason": end_reason_data.name,
            "median_before": f"{read.median_before:.1f}",
            "sample_count": read.sample_count,
            "byte_count": read.byte_count,
            "signal_compression_ratio": f"{read.byte_count / float(read.sample_count*2):.3f}",
            "scale": read.calibration.scale,
            "offset": read.calibration.offset,
            # "range": read.calibration.range,
        }
        print("run info")
        dump_run_info(read.run_info, indent=2)
        yield pod5_read


def pod52slow5(args):
    '''
    pipeline for converting ONT pod5 files to slow5 files
    '''
    pod5_file = args.input
    slow5_file = args.output
    # open slow5 file for writing
    # s5 = pyslow5.Open(slow5_file, 'w')
    # header = s5.get_empty_header()
    # get header info
    # convert to slow5 format
    # write header
    # ret = write_header(header) # limitation: only 1 read group for now
    # Get pod5 reads
    for read in get_all_pod5(pod5_file):
        # convert pod5 read into slow5 read structure
        print(read)
        for k in list(read.keys()):
            print(f"{k}: {read[k]}")
        # do slow5 stuff
        # print("opening file:")
        # s5 = pyslow5.Open(slow5_file, 'r', DEBUG=1)
        # print("opened file..")
        # print()
        # print("slow5 info")
        # s5_read = s5.get_read("000dab68-15a2-43c1-b33d-9598d95b37de", aux='all')
        # heads = s5.get_all_headers()
        # print("header")
        # for k in list(heads.keys()):
        #     print(f"{k}: {heads[k]}")
        # print()
        # print()
        # print("read")
        # for k in list(s5_read.keys()):
        #     if k == "signal":
        #         print(f"{k}: {len(s5_read[k])}")
        #     else:
        #         print(f"{k}: {s5_read[k]}")
        # s5.close()
        sys.exit(1)
        # record, aux = s5.get_empty_record(aux=True)
        # write slow5 read
        # s5.write_record(record, aux)
    # close slow5 file
    # s5.close()

def slow52pod5(args):
    '''
    pipeline for converting slow5 files to ONT pod5 files
    '''
    # figure out pod5 write methods.

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


    if args.command == "p2s":
        pod52slow5(args)
    elif args.command == "s2p":
        slow52pod5(args)
    else:
        parser.print_help(sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
