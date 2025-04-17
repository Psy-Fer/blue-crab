#!/usr/bin/env python3

import argparse
import sys
import os

import pod5 as p5
from pod5.signal_tools import DEFAULT_SIGNAL_CHUNK_SIZE, vbz_compress_signal_chunked


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
        if name == "acquisition_id":
            info_dic["run_id"] = value
    return info_dic


def convert_datetime_as_epoch_ms(time_str):
    '''Convert time string to timestamp'''
    epoch = datetime.datetime.utcfromtimestamp(0).replace(tzinfo=datetime.timezone.utc)
    if time_str is None:
        return epoch
    try:
        return iso8601.parse_date(time_str)
    except iso8601.iso8601.ParseError:
        return epoch

def timestamp_to_int(time_stamp):
    """Convert a datetime timestamp to an integer if it's not already an integer"""
    if isinstance(time_stamp, int):
        return time_stamp
    return int(time_stamp.astimezone(pytz.utc).timestamp() * 1000)

def p2s_end_reason_convert(end_reason):
    '''
    convert end_reason.name into an int for slow5
    '''
    slow5_end_dic = {
            "unknown": 0,
            "partial": 0,
            "mux_change": 1,
            "unblock_mux_change": 2,
            "data_service_unblock_mux_change": 3,
            "signal_positive": 4,
            "signal_negative": 5,
            "api_request": 6,
            "device_data_error": 7,
            "analysis_config_change": 8,
        }

    try:
        ret = slow5_end_dic[end_reason]
    except:
        # logger.error("p2s_end_reason_convert: end_reason - {} - not found, please contact developers".format(end_reason))
        sys.exit(1)
    return ret


def get_data_from_pod5_record(read):
    '''
    yield slow5 reads using input path
    '''
    # return with pod5 format names, do conversion in pipeline
    pore_data = read.pore
    end_reason_data = read.end_reason
    # the lower case string of end_reason
    end_reason = p2s_end_reason_convert(end_reason_data.name)
    end_reason_forced = end_reason_data.forced
    tracked_scaling = read.tracked_scaling
    tracked_scaling_shift = tracked_scaling.shift
    tracked_scaling_scale = tracked_scaling.scale
    predicted_scaling = read.predicted_scaling
    predicted_scaling_shift = predicted_scaling.shift
    predicted_scaling_scale = predicted_scaling.scale
    if pore_data.pore_type not in ["not_set", "R10.4.1", ""]:
        # logger.error("pore_type is '{}' expected to be 'not_set'. Please contact developers with this message.".format(pore_data.pore_type))
        sys.exit(1)

    pod5_read = {
        "read_id": read.read_id,
        "channel": pore_data.channel,
        "well": pore_data.well,
        "pore_type": pore_data.pore_type,
        "read_number": read.read_number,
        "start_sample": read.start_sample,
        "end_reason": end_reason,
        "end_reason_forced": end_reason_forced,
        "median_before": read.median_before,
        "sample_count": read.sample_count,
        "byte_count": read.byte_count,
        "digitisation": read.calibration_digitisation,
        "range": read.calibration_range,
        "signal_compression_ratio": f"{read.byte_count / float(read.sample_count*2):.3f}",
        "scale": read.calibration.scale,
        "offset": read.calibration.offset,
        "signal": read.signal,
        "tracked_scaling_shift": tracked_scaling_shift,
        "tracked_scaling_scale": tracked_scaling_scale,
        "predicted_scaling_shift": predicted_scaling_shift,
        "predicted_scaling_scale": predicted_scaling_scale,
        "num_reads_since_mux_change": read.num_reads_since_mux_change,
        "time_since_mux_change": read.time_since_mux_change,
        "num_minknow_events": read.num_minknow_events,
    }
    info_dic = run_info_to_flat_dic(read.run_info)
    yield pod5_read, info_dic


class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help(sys.stderr)
        sys.exit(2)




def main():

    parser = MyParser(description="pod5 investigations")

    parser.add_argument("input", metavar="POD5",
                    help="pod5 file to investigate")


    args = parser.parse_args()

    # print help if no args given
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    
    header = {}
    head = True
    count = 0
    with p5.Reader(args.input) as reader:
        print("batch count:", reader.batch_count)
        # dir(reader.read_table)
        # help(reader.read_table)
        for pod_read_record in reader.reads():
            # convert pod5 read into slow5 read structure
            # sig_rows = pod_read_record.signal_rows
            # print(pod_read_record.signal_rows)
            for read, info in get_data_from_pod5_record(pod_read_record):
                # write header
                if head:
                    for k in list(info.keys()):
                        header[k] = info[k]
                        print(k, ":", info[k])
                        if k == "sample_frequency":
                            sampling_rate = float(info[k])
                    head = False
                print(pod_read_record.signal_rows)
                print(read)
                count += 1
                if count > 3:
                    sys.exit()





if __name__ == '__main__':
    main()
