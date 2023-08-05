# Old readme

Here are the docs including example commands and workflows for converting between pod5 and s/blow5

If your POD5 files are of version `0.1.5` and read table version `ReadTableVersion.V3` you may also try the following command.
```
python3 ./archived/converter_for_v015.py p2s my_pod5_file.pod5 my_slow5_file.slow5
```

The following command may work with pod5 files with version older than `0.1.5`
```
python3 ./archived/converter_pre_v015.py p2s my_pod5_file.pod5 my_slow5_file.slow5
```

To go back from slow5 to pod5 use the following script. This will use fast5 as an intermediary format.
```
s2p_conversion_alpha.sh input.slow5 output.pod5
```

### Data conversion walkthrough

Here I will attempt to direct the user to become familiar with conversion tools as well as understand the various nanopore signal formats.

A quick overview of files formats. Mostly my opinion.

#### fast5:

Extensions: `.fast5`

The first file format released for nanopore signal data. Based on the HDF5 format, the fast5 scheme contains various metadata along with the signal data. Most metadata is repeated for each read. HDF5 has a major limitation of not being 'thread-efficient' and so cannot use multi-threading. Using multiprocessing is not an efficient workaround either. Fast5 will soon be phased out moving to pod5


#### slow5:

Extensions: `.slow5`-(ASCII) `.blow5`-(binary) `blow5.idx`-(index) (like sam/bam/bai)

Slow5 is a community developed file format and scheme, created from scratch, specifically for nanopore signal data and associated metadata. It is 'thread-efficient', is faster to read than fast5, and has a smaller file size when using similar compression methods. It is specifically designed to reduce the memory footprint, and work efficiently with both SSD/NVME and HDD disks and how they access data. This ensures workloads scale in a performant manner, unlike both fast5 and pod5.


#### pod5:

Extensions: `.pod5`

Pod5 is the second file format released by ONT for nanopore signal data. It is based on the Apache Arrow IPC file format, and it's scheme is the read data, which then has references to the various metadata and signal chunks, which get combined on a read call. In this manner the backend works a bit like a relational SQL database, however the front end API (though still under development) simplifies the access of reads. Reads can be processed with multiprocessing, and the Arrow backend will use all available threads of the machine to help with processing. Overall, pod5 is better than fast5, however it is my opinion slow5 is a more scalable and memory efficient format.



### Converting files

Starting with a fast5, we will convert it to a slow5 with slow5tools, and a pod5 file with the pod5_convert_fast5 tool.
Then we will convert from pod5 to slow5 with the tool in this repo.

#### Install slow5tools:

Follow instructions on setup/install here:
https://github.com/hasindu2008/slow5tools

#### Setup python3 env for both pod5 and pyslow5

```bash
python3 -m venv ./blue_crab_env
source ./blue_crab_env/bin/activate

# allow reading zstd compressed blow5 files
export PYSLOW5_ZSTD=1
python3 -m pip install --upgrade pip
pip install setuptools wheel numpy
pip install pod5_format pod5_format_tools pyslow5
```

# Example data:

Download single fast5 file with 4000 reads. Data is from a human genome sample of NA12878

```bash
wget -O PAF25452_pass_bfdfd1d8_11.fast5 https://www.dropbox.com/s/xck7g8sc80hx02u/PAF25452_pass_bfdfd1d8_11.fast5?dl=1
```

Create folder structure and move fast5 file

```bash
mkdir 1_fast5 1_slow5 1_pod5 p2s
mv PAF25452_pass_bfdfd1d8_11.fast5 1_fast5/
```

### fast5 -> slow5

Convert `.fast5` file to binary compressed `.blow5` file using zstd for metadata compressions and svb-zd for signal compression (equivalent to ONT VBZ compression method)

```bash
slow5tools f2s -c zstd -s svb-zd -d 1_slow5/ 1_fast5/PAF25452_pass_bfdfd1d8_11.fast5
```

### fast5 -> pod5

convert `.fast5` file to pod5 file. Default compression is also using svb-zd on the signal

```bash
pod5-convert-from-fast5 --active-readers 4 1_fast5/ 1_pod5/
```


### pod5 -> slow5

```bash
python3 ./tools/converter.py p2s 1_pod5/output.pod5 f2s/PAF25452_pass_bfdfd1d8_11.blow5
```


## Inspecting results

Using `slow5tools view` we can inspect the results of the pod5->blow5 file and compare to fast5->blow5 (data below)

Here you will see the data is the same, though the aux fields
```
start_time, read_number, start_mux, median_before, channel_number
```
are in a different order. This is within the slow5 spec.

You will find the header will also have some differences, as we dump the metadata from pod5 into the slow5 header, as there are some new/renamed fields.

<!-- One notable difference, is the absence of `end_reason` in our pod5->slow5 file. This is on the list to fix. This field currently isn't used in anything of note we have seen yet, and its history is complicated. It has changed many times in the fast5 files, which makes it difficult to make non breaking compatible code. -->

<!-- One last difference, is in our pod5->blow5 file output, you will note `digitisation=1` and `range` is a float < 1. That is because ONT removed range and digitisation from pod5. While digitisation can be calculated from `adc_max - adc_min`, when converting fast5 files, they are both 0. The reason these are needed are for conversion of the raw signal values into pA values using the following array maths:

```
scale = range / digitisation
pA_signal = scale * (signal + offset)
```

So instead, we set digitisation to 1, and place the scale value in the range column.

This means, if a 3rd party software reads a slow5 file, and wants to calculate pA, the maths goes like this

```
range = 0.365518
digitisation = 1

scale = range / digitisation

0.365518 = 0.365518 / 1
```

So effectively, scale = range, and they are both of the same double/float type.

This way, we don't break other tools while ONT decide how many tools they want to break in the process of finalising the pod5 format. -->

pod5 before version 0.0.17 did not have digitisation or range properly accessible. Re-convert or leave an issue for a fix.


### Conversion outputs

fast5->blow5
```
> slow5tools view 1_slow5/PAF25452_pass_bfdfd1d8_11.blow5 | grep -v ^@ | head -n 10 | cut -f1-7,9-16

#slow5_version	0.2.0
#num_read_groups	1
#char*	uint32_t	double	double	double	double	uint64_t	uint64_t	int32_t	uint8_t	double	enum{unknown,partial,mux_change,unblock_mux_change,signal_positive,signal_negative}	char*
#read_id	read_group	digitisation	offset	range	sampling_rate	len_raw_signal	start_time	read_number	start_mux	median_before	end_reason	channel_number
000dab68-15a2-43c1-b33d-9598d95b37de	0	2048	-223	748.580139	4000	331742	3856185	261	1	204.185028	4	861
00267974-969d-4b5a-9cb9-6f1d68f77725	0	2048	-237	748.580139	4000	180004	3861585	314	2	216.619049	4	1958
00400019-5642-43dc-b333-7ca0a6397f9e	0	2048	-234	748.580139	4000	151713	3976540	225	4	205.611359	4	371
00423c2b-8f22-48b2-a23a-b99cb7ba11b1	0	2048	-227	748.580139	4000	72688	3976965	311	4	206.915344	4	320
0075f4a0-cfd4-4b48-a960-540260239c54	0	2048	-262	748.580139	4000	166818	3872234	298	1	260.620117	4	2386
007f4e5c-45ee-4db4-ae96-5180572a80a3	0	2048	-247	748.580139	4000	187065	3876721	352	3	215.29895	5	1526



```

fast5->pod5->blow5
```
> slow5tools view p2s/PAF25452_pass_bfdfd1d8_11.blow5 | grep -v ^@ | head -n 10 | cut -f1-7,9-16

#slow5_version	0.2.0
#num_read_groups	1
#char*	uint32_t	double	double	double	double	uint64_t	char*	double	int32_t	uint8_t	uint64_t
#read_id	read_group	digitisation	offset	range	sampling_rate	len_raw_signal	channel_number	median_before	read_number	start_mux	start_time
000dab68-15a2-43c1-b33d-9598d95b37de	0	2048	-223	748.580139	4000	331742	861	204.185028	261	1	3856185
00267974-969d-4b5a-9cb9-6f1d68f77725	0	2048	-237	748.580139	4000	180004	1958	216.619049	314	2	3861585
00400019-5642-43dc-b333-7ca0a6397f9e	0	2048	-234	748.580139	4000	151713	371	205.611359	225	4	3976540
00423c2b-8f22-48b2-a23a-b99cb7ba11b1	0	2048	-227	748.580139	4000	72688	320	206.915344	311	4	3976965
0075f4a0-cfd4-4b48-a960-540260239c54	0	2048	-262	748.580139	4000	166818	2386	260.620117	298	1	3872234
007f4e5c-45ee-4db4-ae96-5180572a80a3	0	2048	-247	748.580139	4000	187065	1526	215.29895	352	3	3876721

```
