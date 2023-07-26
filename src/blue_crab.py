#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path
import datetime
import iso8601
import pytz
import uuid
import numpy as np

import pyslow5 as slow5
import pod5 as p5
from pod5.signal_tools import DEFAULT_SIGNAL_CHUNK_SIZE, vbz_compress_signal_chunked

from ._version import __version__


def kill_program():
    ''' exit program due to error '''
    print("ERROR: Error encounted, exiting...")
    sys.exit(1)


class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

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

def s2p_end_reason_convert(end_reason):
    '''
    take an end_reason from slow5, and convert it to the current pod5 format
    mapping "partial" to UNKNOWN as it's no longer used, but can come from old fast5 files
    and so can also come from slow5 files
    '''
    # TODO: make this some static dic so I only build it once
    pod5_end_dic = {
        "unknown": (p5.EndReasonEnum.UNKNOWN, False),
        "partial": (p5.EndReasonEnum.UNKNOWN, False),
        "mux_change": (p5.EndReasonEnum.MUX_CHANGE, True),
        "unblock_mux_change": (p5.EndReasonEnum.UNBLOCK_MUX_CHANGE, True),
        "data_service_unblock_mux_change": (p5.EndReasonEnum.DATA_SERVICE_UNBLOCK_MUX_CHANGE, True),
        "signal_positive": (p5.EndReasonEnum.SIGNAL_POSITIVE, False),
        "signal_negative": (p5.EndReasonEnum.SIGNAL_NEGATIVE, False),
    }

    try:
        ret = pod5_end_dic[end_reason]
    except:
        print("s2p_end_reason_convert: end_reason - {} - not found, please contact developers".format(end_reason))
        sys.exit(1)
    return ret[0], ret[1]

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
        }

    try:
        ret = slow5_end_dic[end_reason]
    except:
        print("p2s_end_reason_convert: end_reason - {} - not found, please contact developers".format(end_reason))
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
    print("INFO: Opening s/blow5 file: {}".format(slow5_file))
    s5 = slow5.Open(slow5_file, 'w')
    header = {}
    sampling_rate = 0
    end_reason_labels = ["unknown", "mux_change", "unblock_mux_change", "data_service_unblock_mux_change", "signal_positive", "signal_negative"]
    # get header info in first read
    # Get pod5 reads
    count = 0
    print("INFO: Reading pod5 file: {}".format(pod5_file))
    with p5.Reader(pod5_file) as reader:
        # TODO: potentially do batches with multiprocessing -> slow5 multithreading
        # total_batchs = reader.batch_count
        # if total_batchs != 1:
        #     print("ERROR: multiple batch support is not implemented for this version of pod5 yet")
        #     exit()
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
                    print("INFO: Writing header - limited to 1 read group for now, split your pod5 if it's a merged file")
                    # TODO: I should dump the full metadata table to figure out the read groups
                    # assign them numbers, then trigger based on read_info to label reads
                    ret = s5.write_header(header, end_reason_labels=end_reason_labels)  # limitation: only 1 read group for now
                    if ret != 0:
                        print("ERROR: Slow5 header not written, see stderr output")
                        kill_program()
                    print("INFO: Slow5 header written")

                if count > 0:
                    for k in list(info.keys()):
                        if k not in prev_info:
                            print("ERROR: {} not in previous run_info".format(k))
                            print("ERROR: More than 1 read_group present - split your pod5")
                            kill_program()
                        if info[k] != prev_info[k]:
                            print("ERROR: {} does not match prev value: 0: {} 1: {}".format(k, prev_info[k], info[k]))
                            print("ERROR: More than 1 read_group present - split your pod5")
                            kill_program()

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
                aux["end_reason"] = int(read["end_reason"] or None)
                aux["tracked_scaling_shift"] = read.get("tracked_scaling_shift", None)
                aux["tracked_scaling_scale"] = read.get("tracked_scaling_scale", None)
                aux["predicted_scaling_shift"] = read.get("predicted_scaling_shift", None)
                aux["predicted_scaling_scale"] = read.get("predicted_scaling_scale", None)
                aux["num_reads_since_mux_change"] = read.get("num_reads_since_mux_change", None)
                aux["time_since_mux_change"] = read.get("time_since_mux_change", None)
                aux["num_minknow_events"] = read.get("num_minknow_events", None)

                # write slow5 read
                s5.write_record(record, aux)
                count += 1
                prev_info = info
    # close slow5 file
    s5.close()

def slow52pod5(args):
    '''
    pipeline for converting slow5 files to ONT pod5 files
    '''
    slow5_file = args.input
    pod5_file = args.output
    print("INFO: Opening s/blow5 file: {}".format(slow5_file))
    # open slow5 file for writing
    s5 = slow5.Open(slow5_file, 'r')
    # get header (don't know read_group_num yet, so need to do slow way of lookup every read....lame, i'll fix this)
    # i'll at least do a cache...
    headers = {}
    # headers = s5.get_all_headers()
    # create slow5 reads generator
    reads = s5.seq_reads(aux='all')
    try:
        slow5_end_reason_labels = s5.get_aux_enum_labels("end_reason")
    except:
        slow5_end_reason_labels = ['unknown']
    run_info_cache = {}
    # before ONT added DATA_SERVICE_UNBLOCK_MUX_CHANGE in the middle and removed partial...
    # slow5_end_reason_labels = ['unknown', 'partial', 'mux_change', 'unblock_mux_change', 'signal_positive', 'signal_negative']
    with p5.Writer(pod5_file) as writer:
        for read in reads:
            '''
            TODO: new aux fields needed in slow5 - need to allow user defined aux fields/types in pythin API
            -num_minknow_events,
            -tracked_scaling_scale,
            -tracked_scaling_shift,
            -predicted_scaling_scale,
            -predicted_scaling_shift,
            -num_reads_since_mux_change,
            -time_since_mux_change,
            '''
            # TODO: try/except around this and give meaninful error
            # Populate container classes for read metadata
            read_group = read["read_group"]
            if read_group in headers:
                header = headers[read_group]
            else:
                headers[read_group] = s5.get_all_headers(read_group=read_group)
                header = headers[read_group]
            pore = p5.Pore(channel=read["channel_number"], well=read["start_mux"], pore_type=header.get("pore_type", "not_set"))
            read_number = read["read_number"]
            start_sample = read["start_time"]
            # scale = range / digitisation
            scale = read["range"] / read["digitisation"]
            calibration = p5.Calibration(offset=read["offset"], scale=scale)
            median_before = read["median_before"]
            # sampling_frequency = read["sampling_rate"]
            # map end_reason if present
            # let's convert this to it's string equivalent
            s5_end_reason = slow5_end_reason_labels[read.get("end_reason", 0)]
            reason, forced = s2p_end_reason_convert(s5_end_reason)
            end_reason = p5.EndReason(reason=reason, forced=forced)
    
            #https://github.com/nanoporetech/pod5-file-format/blob/master/python/pod5/src/pod5/tools/pod5_convert_from_fast5.py#L401
            
            # cache the run_info and re-use based on acquisition_id
            acq_id = header["run_id"]
            
            if acq_id not in run_info_cache:
                acquisition_id = header.get("run_id", "")
                protocol_name = header.get("exp_script_name", "")
                acquisition_start_time = header.get("exp_start_time", "")
                sequencer_position = header.get("device_id", "")
                system_name = header.get("host_product_serial_number", "")
                system_type = header.get("host_product_code", "")
                adc_min = 0
                adc_max = 2047
                sequencer_position_type = header.get("device_type", "promethion")
                if read["digitisation"] == 8192:
                    adc_min = -4096
                    adc_max = 4095
                    sequencer_position_type = header.get("device_type", "minion")

                context_list = [
                    "barcoding_enabled",
                    "basecall_config_filename",
                    "experiment_duration_set",
                    "experiment_type",
                    "local_basecalling",
                    "package",
                    "package_version",
                    "sample_frequency",
                    "sequencing_kit",
                ]
                context_tags = {}

                for key in context_list:
                    a = header.get(key, "")
                    if a is None:
                        a = ""
                    context_tags[key] = a

                tracking_list = [
                    "asic_id",
                    "asic_id_eeprom",
                    "asic_temp",
                    "asic_version",
                    "auto_update",
                    "auto_update_source",
                    "bream_is_standard",
                    "configuration_version",
                    "device_id",
                    "device_type",
                    "distribution_status",
                    "distribution_version",
                    "exp_script_name",
                    "exp_script_purpose",
                    "exp_start_time",
                    "flow_cell_id",
                    "flow_cell_product_code",
                    "guppy_version",
                    "heatsink_temp",
                    "hostname",
                    "hublett_board_id",
                    "hublett_firmware_version",
                    "installation_type",
                    "ip_address",
                    "local_firmware_file",
                    "mac_address",
                    "operating_system",
                    "protocol_group_id",
                    "protocol_run_id",
                    "protocols_version",
                    "run_id",
                    "sample_id",
                    "satellite_board_id",
                    "satellite_firmware_version",
                    "usb_config",
                    "version"
                ]
                                 
                tracking_id = {}

                for key in tracking_list:
                    a = header.get(key, "")
                    if a is None:
                        a = ""
                    tracking_id[key] = a
                '''
                +acquisition_id=acq_id,
                +acquisition_start_time=convert_datetime_as_epoch_ms(
                    tracking_id.get("exp_start_time")
                ),
                +adc_max=adc_max,
                +adc_min=adc_min,
                +context_tags={
                    str(key): decode_str(value) for key, value in context_tags.items()
                },
                +experiment_name="",
                +flow_cell_id=decode_str(tracking_id.get("flow_cell_id", b"")),
                +flow_cell_product_code=decode_str(
                    tracking_id.get("flow_cell_product_code", b"")
                ),
                +protocol_name=decode_str(tracking_id.get("exp_script_name", b"")),
                +protocol_run_id=decode_str(tracking_id.get("protocol_run_id", b"")),
                +protocol_start_time=convert_datetime_as_epoch_ms(
                    tracking_id.get("protocol_start_time", None)
                ),
                +sample_id=decode_str(tracking_id.get("sample_id", b"")),
                +sample_rate=sample_rate,
                +sequencing_kit=decode_str(context_tags.get("sequencing_kit", b"")),
                +sequencer_position=decode_str(tracking_id.get("device_id", b"")),
                +sequencer_position_type=decode_str(tracking_id.get("device_type", device_type)),
                +software="python-pod5-converter",
                +system_name=decode_str(tracking_id.get("host_product_serial_number", b"")),
                +system_type=decode_str(tracking_id.get("host_product_code", b"")),
                +tracking_id={str(key): decode_str(value) for key, value in tracking_id.items()},
                arg0: str, 'bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f'
                arg1: int, 1603777310000
                arg2: int, 2047
                arg3: int, 0
                arg4: List[Tuple[str, str]], [('barcoding_enabled', '0'), ('basecall_config_filename', 'dna_r9.4.1_450bps_hac_prom.cfg'), ('experiment_duration_set', '4320'), ('experiment_type', 'genomic_dna'), ('local_basecalling', '1'), ('package', 'bream4'), ('package_version', '6.0.7'), ('sample_frequency', '4000'), ('sequencing_kit', 'sqk-lsk109')]
                arg5: str,None
                arg6: str,'PAF25452'
                arg7: str,'FLO-PRO002'
                arg8: str,'sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109'
                arg9: str,'97d631c6-c622-473d-9e7d-3cb9297b0036'
                arg10: int,0
                arg11: str,'NA12878_SRE'
                arg12: int,4000
                arg13: str,'sqk-lsk109'
                arg14: str,'3A'
                arg15: str,'promethion'
                arg16: str,'blue-crab SLOW5<->POD5 converter'
                arg17: str,None
                arg18: str,None
                arg19: List[Tuple[str, str]])[('asic_id', '0004A30B00F25467'), ('asic_id_eeprom', '0004A30B00F25467'), ('asic_temp', '31.996552'), ('asic_version', 'Unknown'), ('auto_update', '0'), ('auto_update_source', 'https://mirror.oxfordnanoportal.com/software/MinKNOW/'), ('bream_is_standard', '0'), ('configuration_version', '4.0.13'), ('device_id', '3A'), ('device_type', 'promethion'), ('distribution_status', 'stable'), ('distribution_version', '20.06.9'), ('exp_script_name', 'sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109'), ('exp_script_purpose', 'sequencing_run'), ('exp_start_time', '2020-10-27T05:41:50Z'), ('flow_cell_id', 'PAF25452'), ('flow_cell_product_code', 'FLO-PRO002'), ('guppy_version', '4.0.11+f1071ce'), ('heatsink_temp', '32.164288'), ('hostname', 'PC24A004'), ('hublett_board_id', '013b01308fa78662'), ('hublett_firmware_version', '2.0.14'), ('installation_type', 'nc'), ('ip_address', 'None'), ('local_firmware_file', '1'), ('mac_address', 'None'), ('operating_system', 'ubuntu 16.04'), ('protocol_group_id', 'PLPN243131'), ('protocol_run_id', '97d631c6-c622-473d-9e7d-3cb9297b0036'), ('protocols_version', '6.0.7'), ('run_id', 'bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f'), ('sample_id', 'NA12878_SRE'), ('satellite_board_id', '013c763bef6cca9d'), ('satellite_firmware_version', '2.0.14'), ('usb_config', 'firm_1.2.3_ware#rbt_4.5.6_rbt#ctrl#USB3'), ('version', '4.0.3')]
                Invoked with: <lib_pod5.pod5_format_pybind.FileWriter object at 0x7fbec82150b0>
                , , , , , , , , , , , , , , , , , , , , 


                '''
                run_info = p5.RunInfo(
                    acquisition_id = header.get("acquisition_id", acquisition_id),
                    acquisition_start_time = timestamp_to_int(convert_datetime_as_epoch_ms(header.get("acquisition_start_time", acquisition_start_time))),
                    adc_max = int(header.get("adc_max", adc_max)),
                    adc_min = int(header.get("adc_min", adc_min)),
                    context_tags = context_tags,
                    experiment_name = str(header.get("experiment_name", "") or ""),
                    flow_cell_id = str(header.get("flow_cell_id", "") or ""),
                    flow_cell_product_code = str(header.get("flow_cell_product_code", "") or ""),
                    protocol_name = str(header.get("protocol_name", protocol_name) or ""),
                    protocol_run_id = str(header.get("protocol_run_id", "") or ""),
                    protocol_start_time = int(timestamp_to_int(convert_datetime_as_epoch_ms(header.get("protocol_start_time", None))) or 0),
                    sample_id = str(header.get("sample_id", "") or ""),
                    sample_rate = int(read["sampling_rate"]),
                    sequencing_kit = str(header.get("sequencing_kit", "") or ""),
                    sequencer_position = str(header.get("sequencer_position", sequencer_position) or ""),
                    sequencer_position_type = str(header.get("sequencer_position_type", sequencer_position_type) or ""),
                    software = "blue-crab SLOW5<->POD5 converter",
                    system_name = str(header.get("system_name", system_name) or ""),
                    system_type = str(header.get("system_type", system_type) or ""),
                    tracking_id = tracking_id
                )
                run_info_cache[acq_id] = run_info


            # Signal conversion process
            signal = read["signal"]
            signal_chunks, signal_chunk_lengths = vbz_compress_signal_chunked(
                signal, DEFAULT_SIGNAL_CHUNK_SIZE
            )
            read = p5.CompressedRead(
                read_id=uuid.UUID(read["read_id"]),
                end_reason=end_reason,
                calibration=calibration,
                pore=pore,
                run_info=run_info_cache[acq_id],
                median_before=median_before,
                read_number=read_number,
                start_sample=start_sample,
                signal_chunks=signal_chunks,
                signal_chunk_lengths=signal_chunk_lengths,
                tracked_scaling=p5.pod5_types.ShiftScalePair(
                    read.get("tracked_scaling_shift", float("nan")),
                    read.get("tracked_scaling_scale", float("nan")),
                ),
                predicted_scaling=p5.pod5_types.ShiftScalePair(
                    read.get("predicted_scaling_shift", float("nan")),
                    read.get("predicted_scaling_scale", float("nan")),
                ),
                num_reads_since_mux_change=read.get("num_reads_since_mux_change", 0),
                time_since_mux_change=read.get("time_since_mux_change", 0.0),
                num_minknow_events=read.get("num_minknow_events", 0),
            )

            
            # Write the read object
            writer.add_read(read)




def main():

    VERSION = __version__

    parser = MyParser(description="SLOW5/BLOW5 <-> POD5 converter",
    epilog="Citation:...",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    # Create submodules
    subcommand = parser.add_subparsers(help='subcommand --help for help messages', dest="command")

    # POD5 to SLOW5
    p2s = subcommand.add_parser('p2s', help='POD5 -> SLOW5/BLOW5',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p2s.add_argument("input", type=Path,
                     help="pod5 file to convert")
    p2s.add_argument("output",
                     help="s/blow5 file to save")

    # SLOW5 to POD5
    s2p = subcommand.add_parser('s2p', help='SLOW5/BLOW5 -> POD5',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    s2p.add_argument("input",
                     help="s/blow5 file to convert")
    s2p.add_argument("output", type=Path,
                     help="pod5 file to save")

    parser.add_argument("-v", "--version", action='version', version="SLOW5/BLOW5 <-> POD5 converter version: {}".format(VERSION),
                        help="Prints version")

    args = parser.parse_args()

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    if args.command == "p2s":
        pod52slow5(args)
        print("INFO: pod5 -> s/blow5 complete")
    elif args.command == "s2p":
        slow52pod5(args)
        print("INFO: s/blow5 -> pod5 complete")
    else:
        parser.print_help(sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
