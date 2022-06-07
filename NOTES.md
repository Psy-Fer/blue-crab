


### dir() and vars() dumps of pod5.

Need to clean these up and match them with slow5 attributes

#### dir(file)
['__class__', '__del__', '__delattr__', '__dict__', '__dir__', '__doc__', '__enter__', '__eq__', '__exit__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_cached_calibrations', '_cached_end_reasons', '_cached_pores', '_cached_run_infos', '_cached_signal_batches', '_get_signal_batch', '_is_vbz_compressed', '_lookup_calibration', '_lookup_dict_value', '_lookup_end_reason', '_lookup_pore', '_lookup_run_info', '_plan_traversal', '_read_reader', '_read_some_batches', '_reader', '_reads', '_reads_batches', '_select_read_batches', '_select_reads', '_signal_batch_row_count', '_signal_reader', 'batch_count', 'close', 'get_batch', 'read_batches', 'reads']

#### vars(file)
{'_reader': <pod5_format.pod5_format_pybind.Pod5FileReader object at 0x7efc88225db0>, '_read_reader': <pod5_format.reader.SubFileReader object at 0x7efc8820cd00>, '_signal_reader': <pod5_format.reader.SubFileReader object at 0x7efc8820cc70>, '_cached_signal_batches': {}, '_cached_run_infos': {}, '_cached_end_reasons': {}, '_cached_calibrations': {}, '_cached_pores': {}, '_is_vbz_compressed': True, '_signal_batch_row_count': 100}

#### dir(read)
['__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_batch', '_batch_signal_cache', '_find_signal_row_index', '_get_signal_for_row', '_reader', '_row', '_selected_batch_index', 'byte_count', 'calibration', 'calibration_index', 'end_reason', 'end_reason_index', 'has_cached_signal', 'median_before', 'pore', 'pore_index', 'read_id', 'read_number', 'run_info', 'run_info_index', 'sample_count', 'signal', 'signal_for_chunk', 'signal_rows', 'start_sample']

#### vars(read)
{'_reader': <pod5_format.reader_pyarrow.FileReader object at 0x7efc8820cdc0>, '_batch': <pod5_format.reader_pyarrow.ReadBatchPyArrow object at 0x7efc8820ce80>, '_row': 0, '_batch_signal_cache': None, '_selected_batch_index': None}


#### read.run_info dump

run info
    acquisition_id: bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f
    acquisition_start_time: 2020-10-27 05:41:50+00:00
    adc_max: 0
    adc_min: 0
    context_tags
      barcoding_enabled: 0
      basecall_config_filename: dna_r9.4.1_450bps_hac_prom.cfg
      experiment_duration_set: 4320
      experiment_type: genomic_dna
      local_basecalling: 1
      package: bream4
      package_version: 6.0.7
      sample_frequency: 4000
      sequencing_kit: sqk-lsk109
    experiment_name:
    flow_cell_id: PAF25452
    flow_cell_product_code: FLO-PRO002
    protocol_name: sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109
    protocol_run_id: 97d631c6-c622-473d-9e7d-3cb9297b0036
    protocol_start_time: 1970-01-01 00:00:00+00:00
    sample_id: NA12878_SRE
    sample_rate: 4000
    sequencing_kit: sqk-lsk109
    sequencer_position: 3A
    sequencer_position_type: promethion
    software: python-pod5-converter
    system_name:
    system_type:
    tracking_id
      asic_id: 0004A30B00F25467
      asic_id_eeprom: 0004A30B00F25467
      asic_temp: 31.996552
      asic_version: Unknown
      auto_update: 0
      auto_update_source: https://mirror.oxfordnanoportal.com/software/MinKNOW/
      bream_is_standard: 0
      configuration_version: 4.0.13
      device_id: 3A
      device_type: promethion
      distribution_status: stable
      distribution_version: 20.06.9
      exp_script_name: sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109
      exp_script_purpose: sequencing_run
      exp_start_time: 2020-10-27T05:41:50Z
      flow_cell_id: PAF25452
      flow_cell_product_code: FLO-PRO002
      guppy_version: 4.0.11+f1071ce
      heatsink_temp: 32.164288
      hostname: PC24A004
      hublett_board_id: 013b01308fa78662
      hublett_firmware_version: 2.0.14
      installation_type: nc
      ip_address:
      local_firmware_file: 1
      mac_address:
      operating_system: ubuntu 16.04
      protocol_group_id: PLPN243131
      protocol_run_id: 97d631c6-c622-473d-9e7d-3cb9297b0036
      protocols_version: 6.0.7
      run_id: bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f
      sample_id: NA12878_SRE
      satellite_board_id: 013c763bef6cca9d
      satellite_firmware_version: 2.0.14
      usb_config: firm_1.2.3_ware#rbt_4.5.6_rbt#ctrl#USB3
      version: 4.0.3

### pod5_read dic output so far

read_id: 000dab68-15a2-43c1-b33d-9598d95b37de
channel: 861
well: 1
pore_type: not_set
read_number: 261
start_sample: 3856185
end_reason: data_service_unblock_mux_change
median_before: 204.2
sample_count: 331742
byte_count: 226302
signal_compression_ratio: 0.341
scale: 0.36551764607429504
offset: -223.0



### slow5 output same read

#### read aux='all'
read_id: 000dab68-15a2-43c1-b33d-9598d95b37de
read_group: 0
digitisation: 2048.0
offset: -223.0
range: 748.5801391601562
sampling_rate: 4000.0
len_raw_signal: 331742
signal: 331742
start_time: 3856185
read_number: 261
start_mux: 1
median_before: 204.18502807617188
end_reason: 4
channel_number: 861

#### header
asic_id: 0004A30B00F25467
asic_id_eeprom: 0004A30B00F25467
asic_temp: 31.996552
asic_version: Unknown
auto_update: 0
auto_update_source: https://mirror.oxfordnanoportal.com/software/MinKNOW/
barcoding_enabled: 0
basecall_config_filename: dna_r9.4.1_450bps_hac_prom.cfg
bream_is_standard: 0
configuration_version: 4.0.13
device_id: 3A
device_type: promethion
distribution_status: stable
distribution_version: 20.06.9
exp_script_name: sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109
exp_script_purpose: sequencing_run
exp_start_time: 2020-10-27T05:41:50Z
experiment_duration_set: 4320
experiment_type: genomic_dna
file_type: multi-read
file_version: 2.2
flow_cell_id: PAF25452
flow_cell_product_code: FLO-PRO002
guppy_version: 4.0.11+f1071ce
heatsink_temp: 32.164288
hostname: PC24A004
hublett_board_id: 013b01308fa78662
hublett_firmware_version: 2.0.14
installation_type: nc
ip_address: None
local_basecalling: 1
local_firmware_file: 1
mac_address: None
operating_system: ubuntu 16.04
package: bream4
package_version: 6.0.7
pore_type: not_set
protocol_group_id: PLPN243131
protocol_run_id: 97d631c6-c622-473d-9e7d-3cb9297b0036
protocols_version: 6.0.7
run_id: bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f
sample_frequency: 4000
sample_id: NA12878_SRE
satellite_board_id: 013c763bef6cca9d
satellite_firmware_version: 2.0.14
sequencing_kit: sqk-lsk109
usb_config: firm_1.2.3_ware#rbt_4.5.6_rbt#ctrl#USB3
version: 4.0.3


### Conversion table


slow5 : pod5

#### header
"asic_id": tracking_id.asic_id,
"asic_id_eeprom": tracking_id.asic_id_eeprom,
"asic_temp": tracking_id.asic_temp,
"asic_version": tracking_id.asic_version,
"auto_update": tracking_id.auto_update,
"auto_update_source": tracking_id.auto_update_source,
"barcoding_enabled": context_tags,
"bream_is_standard": tracking_id,
"configuration_version": tracking_id,
"device_id": tracking_id,
"device_type": tracking_id,
"distribution_status": tracking_id,
"distribution_version": tracking_id,
"exp_script_name": tracking_id,
"exp_script_purpose": tracking_id,
"exp_start_time": tracking_id,
"experiment_duration_set": context_tags,
"flow_cell_id": tracking_id, AND run_info
"flow_cell_product_code": tracking_id, AND run_info
"guppy_version": tracking_id,
"heatsink_temp": tracking_id,
"hostname": tracking_id,
"installation_type": tracking_id,
"local_basecalling": context_tags,
"operating_system": tracking_id,
"package": context_tags,
"protocol_group_id": tracking_id,
"protocol_run_id": tracking_id, AND run_info
"protocol_start_time": None,
"protocols_version": tracking_id,
"run_id": tracking_id,
"sample_frequency": context_tags,
"sample_id": tracking_id, AND run_info
"sequencing_kit": context_tags, AND run_info
"usb_config": tracking_id,
"version": tracking_id,
"hublett_board_id": tracking_id,
"satellite_firmware_version": tracking_id}


#### read

read_id: 000dab68-15a2-43c1-b33d-9598d95b37de = read_id
read_group: 0
digitisation: 2048.0 = ? if can't get it, make it 1
offset: -223.0 = calibration.offset
range: 748.5801391601562 = ? if can't get it, make it scale
sampling_rate: 4000.0 = sample_frequency in read_info
len_raw_signal: 331742 = sample_count
signal: 331742 = ?
start_time: 3856185 = start_sample
read_number: 261 = read_number
start_mux: 1 = well
median_before: 204.18502807617188 = median_before
end_reason: 4 = end_reads BUT converted to text value
channel_number: 861 = channel





acquisition_id: bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f
acquisition_start_time: 2020-10-27 05:41:50+00:00
adc_max: 0
adc_min: 0
barcoding_enabled: 0
basecall_config_filename: dna_r9.4.1_450bps_hac_prom.cfg
experiment_duration_set: 4320
experiment_type: genomic_dna
local_basecalling: 1
package: bream4
package_version: 6.0.7
sample_frequency: 4000
sequencing_kit: sqk-lsk109
experiment_name:
flow_cell_id: PAF25452
flow_cell_product_code: FLO-PRO002
protocol_name: sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109
protocol_run_id: 97d631c6-c622-473d-9e7d-3cb9297b0036
protocol_start_time: 1970-01-01 00:00:00+00:00
sample_id: NA12878_SRE
sample_rate: 4000
sequencer_position: 3A
sequencer_position_type: promethion
software: python-pod5-converter
system_name:
system_type:
asic_id: 0004A30B00F25467
asic_id_eeprom: 0004A30B00F25467
asic_temp: 31.996552
asic_version: Unknown
auto_update: 0
auto_update_source: https://mirror.oxfordnanoportal.com/software/MinKNOW/
bream_is_standard: 0
configuration_version: 4.0.13
device_id: 3A
device_type: promethion
distribution_status: stable
distribution_version: 20.06.9
exp_script_name: sequencing/sequencing_PRO002_DNA:FLO-PRO002:SQK-LSK109
exp_script_purpose: sequencing_run
exp_start_time: 2020-10-27T05:41:50Z
guppy_version: 4.0.11+f1071ce
heatsink_temp: 32.164288
hostname: PC24A004
hublett_board_id: 013b01308fa78662
hublett_firmware_version: 2.0.14
installation_type: nc
ip_address:
local_firmware_file: 1
mac_address:
operating_system: ubuntu 16.04
protocol_group_id: PLPN243131
protocols_version: 6.0.7
run_id: bfdfd1d840e2acaf5c061241fd9b8e5c3cfe729f
satellite_board_id: 013c763bef6cca9d
satellite_firmware_version: 2.0.14
usb_config: firm_1.2.3_ware#rbt_4.5.6_rbt#ctrl#USB3
version: 4.0.3






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
}

py_record_types = {"read_id": type("string"), x
                   "read_group": type(1), x
                   "digitisation": type(1.0),
                   "offset": type(1.0), x
                   "range": type(1.0),
                   "sampling_rate": type(1.0), x
                   "len_raw_signal": type(10),
                   "signal": type(np.array([1, 2, 3], np.int16))}

py_aux_types = {"channel_number": type("string"),
                "median_before": type(1.0),
                "read_number": type(10),
                "start_mux": type(1),
                "start_time": type(100),
                "end_reason": None}
