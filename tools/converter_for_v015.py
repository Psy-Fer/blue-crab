#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path
import numpy as np
import pyslow5
import pod5 as p5

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

def kill_program():
    ''' exit program due to error '''
    print("ERROR: Error encounted, exiting...")
    sys.exit(1)


def run_info_to_flat_dic(run_info):
    info_dic = {}
    for name, value in run_info.__dict__.items():
        if isinstance(value, list):
            for k, v in value:
                info_dic[k] = v
        elif isinstance(value, dict):
            for key in value:
                info_dic[key] = value[key]
        else:
            info_dic[name] = value
    return info_dic


def get_data_from_pod5_record(read):
    '''
    yield slow5 reads using input path
    '''
    # return with pod5 format names, do conversion in pipeline
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
        "median_before": read.median_before,
        "sample_count": read.sample_count,
        "byte_count": read.byte_count,
        "digitisation": read.calibration_digitisation,
        "range": read.calibration_range,
        "signal_compression_ratio": f"{read.byte_count / float(read.sample_count*2):.3f}",
        "scale": read.calibration.scale,
        "offset": read.calibration.offset,
        "signal": read.signal
    }
    info_dic = run_info_to_flat_dic(read.run_info)
    yield pod5_read, info_dic


def pod52slow5(args):
    '''
    pipeline for converting ONT pod5 files to slow5 files
    '''
    pod5_file = args.input
    slow5_file = args.output
    # open slow5 file for writing
    print("INFO: Opening slow5 file: {}".format(slow5_file))
    s5 = pyslow5.Open(slow5_file, 'w')
    header = {}
    sampling_rate = 0
    # get header info in first read
    # Get pod5 reads
    count = 0
    print("INFO: Reading pod5 file: {}".format(pod5_file))
    with p5.Reader(pod5_file) as reader:
        total_batchs = reader.batch_count
        if total_batchs != 1:
            print("ERROR: multiple batch support is not implemented for this version of pod5 yet")
            exit()
        for pod_read_record in reader.reads():
            # convert pod5 read into slow5 read structure
            for read, info in get_data_from_pod5_record(pod_read_record):
                if count == 0:
                    # write header
                    for k in list(info.keys()):
                        # if k not in header:
                        #     print(f"WARNING: {k} not found in default slow5 header, adding it")
                        header[k] = info[k]
                        if k == "sample_frequency":
                            sampling_rate = float(info[k])
                    print("INFO: Writing header...")
                    ret = s5.write_header(header)  # limitation: only 1 read group for now
                    if ret != 0:
                        print("ERROR: Slow5 header not written, see stderr output")
                        kill_program()
                    print("INFO: Slow5 header written")

                if count > 0:
                    for k in list(info.keys()):
                        if k not in prev_info:
                            print("ERROR: {} not in previous run_info".format(k))
                        if info[k] != prev_info[k]:
                            print("ERROR: {} does not match prev value: 0: {} 1: {}".format(k, prev_info[k], info[k]))

                # do slow5 stuff
                record, aux = s5.get_empty_record(aux=True)
                # convert pod5 -> slow5
                record['read_id'] = str(read["read_id"])
                record['read_group'] = 0
                record['offset'] = float(read["offset"])
                record['sampling_rate'] = sampling_rate
                record['len_raw_signal'] = int(read["sample_count"])
                record['signal'] = np.array(read["signal"], np.int16)
                record['digitisation'] = float(read["digitisation"])
                record['range'] = float(read["range"])
                # aux fields
                aux["channel_number"] = str(read["channel"])
                aux["median_before"] = float(read["median_before"])
                aux["read_number"] = int(read["read_number"])
                aux["start_mux"] = int(read["well"])
                aux["start_time"] = int(read["start_sample"])
                # end reason will be lost for now...it's complicated
                # aux["end_reason"] = str(read["end_reason"])

                # write slow5 read
                s5.write_record(record, aux)
                count += 1
                prev_info = info
    # close slow5 file
    s5.close()

# def slow52pod5(args):
#     '''
#     pipeline for converting slow5 files to ONT pod5 files
#     '''
#     # figure out pod5 write methods.

def main():

    VERSION = "v0.0.3"

    parser = MyParser(description="POD5 to SLOW5 converter",
    epilog="Citation:...",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    # Create submodules
    subcommand = parser.add_subparsers(help='subcommand --help for help messages', dest="command")

    # POD5 to SLOW5
    p2s = subcommand.add_parser('p2s', help='POD5 -> SLOW5',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p2s.add_argument("input", type=Path)
    p2s.add_argument("output")

    parser.add_argument("-v", "--version", action='version', version="SLOW5 <-> POD5 converter version: {}".format(VERSION),
                        help="Prints version")

    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)


    if args.command == "p2s":
        pod52slow5(args)
        print("INFO: pod5 -> slow5 complete")
    else:
        parser.print_help(sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
