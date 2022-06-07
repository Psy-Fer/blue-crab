# project_blue_crab
crab go snap snap

### Usage
```
python3 ./tools/converter.py p2s my_pod5_file.pod5 my_slow5_file.slow5
```

### Data conversion walkthrough

Here I will attempt to direct the user to become familiar with conversion tools as well as understand the various nanopore signal formats.

A quick overview of files formats. Mostly my opinion.

#### fast5:

Extensions: `.fast5`

The first file format released for nanopore signal data. Based on the HDF5 format, the fast5 scheme contains various metadata along with the signal data. Most metadata is repeated for each read. HDF5 has a major limitation of not being 'thread-safe' and so cannot use multi-threading. Using multiprocessing is not an efficient workaround either. Fast5 will soon be phased out moving to pod5


#### slow5:

Extensions: `.slow5`-(ASCII) `.blow5`-(binary) `blow5.idx`-(index) (like sam/bam/bai)

Slow5 is a community developed file format and scheme, created from scratch, specifically for nanopore signal data and associated metadata. It is 'thread-safe', is faster the read than fast5, and has a smaller file size when using similar compression methods. It is specifically designed to reduce memory footprint, and work efficiently with both SSD/NVME and HDD disks and how they access data. This ensures workloads scale in a performant manner, unlike both fast5 and pod5.


#### pod5:

Extensions: `.pod5`

Pod5 is the second file format released by ONT for nanopore signal data. It is based on the Apache Arrow IPC file format, and it's scheme is the read data, which then has references to the various metadata and signal chunks, which get combined on a read call. In this manner the backend works a bit like a relational SQL database, however the front end API (though still under development) simplifies the access of reads. Reads can be processed with multiprocessing, and the Arrow backend will use all available threads of the machine to help with processing.



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

Download single fast5 file with 4000 reads

```bash
wget -O PAF25452_pass_bfdfd1d8_11.fast5 https://www.dropbox.com/s/xck7g8sc80hx02u/PAF25452_pass_bfdfd1d8_11.fast5?dl=1
```

Create folder structure

```bash
mkdir 1_fast5 1_slow5 1_pod5 p2s
```

### fast5 -> slow5

```bash

```

### fast5 -> pod5

```bash

```


### pod5 -> slow5

```bash

```
