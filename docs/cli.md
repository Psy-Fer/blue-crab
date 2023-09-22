# Commands and Options

## COMMANDS

* `p2s`:<br/>
         Convert POD5 files to SLOW5/BLOW5 format.
* `s2p`:<br/>
         Convert SLOW5/BLOW5 files to POD5 format.

### p2s

```
blue-crab p2s [OPTIONS] pod5_dir1 -d output_dir
blue-crab p2s [OPTIONS] pod5_dir1 pod5_dir2 ... -d output_dir
blue-crab p2s [OPTIONS] file1.pod5 file2.pod5 ... -d output_dir
blue-crab p2s [OPTIONS] file.pod5 -o output.blow5
blue-crab p2s [OPTIONS] file.pod5 -o output.slow5
```

Converts POD5 files to SLOW5/BLOW5 format.
The input can be a single POD5 file, a list of POD5 files, a directory containing multiple POD5 files, or a list of directories. If a directory is provided, the tool recursively searches within for POD5 files (.pod5 extension) and converts them to SLOW5/BLOW5.
For each POD5 file in the input directories, a SLOW5/BLOW5 file with the same file name will be created inside the output directory (specified with `-d`).
Note: Before converting a POD5 file having multiple run IDs (aka acquisition IDs), split the file into groups using ONT's pod5 tool.

*  `-d, --out-dir STR`:<br/>
   Specifies name/location of the output directory. Incompatible with `-o`. If a name is provided, a directory will be created under the current working directory. Alternatively, a valid relative or absolute path can be provided. To prevent data overwriting, the program will terminate with error if the directory name already exists and is non-empty.
*  `-o, --output FILE`:<br/>
   When only one POD5 file is being converted, `-o` specifies a single FILE to which output data is written. Incompatible with `-d` and will automatically detect the output format from the file extension.
*  `-c, --compress compression_type`:<br/>
   Specifies the compression method used for BLOW5 output. `compression_type` can be `none` for uncompressed binary; `zlib` for zlib-based (also known as gzip or DEFLATE) compression; or `zstd` for Z-standard-based compression [default value: zlib]. This option is only valid for BLOW5. `zstd` will only function if blue-crab has been built with zstd support which is turned off by default.
*  `-s, --sig-compress compression_type`:<br/>
   Specifies the raw signal compression method used for BLOW5 output. `compression_type` can be `none` for uncompressed raw signal or `svb-zd` to compress the raw signal using StreamVByte zig-zag delta [default value: svb-zd]. This option is introduced from pyslow5 v0.3.0 onwards. Note that record compression (-c option above) is still applied on top of the compressed signal. Signal compression with svb-zd and record compression with zstd is similar to ONT's vbz.  zstd+svb-zd offers slightly smaller file size and slightly better performance compared to the default zlib+svb-zd, however, will be less portable.
*  `-p, --iop INT`:<br/>
    Specifies the number of I/O processes to use during conversion [default value: 4]. Increasing the number of I/O processes makes p2s significantly faster, especially on HPC with RAID systems (multiple disks) where a large value number of processes can be used (e.g., `-p 64`).
* `-t, --threads INT`:<br/>
    Number of threads used for encoding S/BLOW5 records [default value: 8].
* `-K, --batchsize`:<br/>
    The batch size used for encoding S/BLOW5 records. This is the number of S/BLOW5 records on the memory at once [default value: 1000]. An increased batch size improves multi-threaded performance at cost of higher RAM.
*  `--retain`:<br/>
	Retain the same directory structure in the converted output as the input.
*  `-h, --help`:<br/>
    Prints the help menu.


### s2p

```
blue-crab s2p [OPTIONS] file1.blow5 -o output.pod5
blue-crab s2p [OPTIONS] blow5_dir1 -d pod5_dir
blue-crab s2p [OPTIONS] file1.blow5 file2.blow5 ... -d pod5_dir
blue-crab s2p [OPTIONS] blow5_dir1 blow5_dir2 ... -d pod5_dir
```

Converts SLOW5/BLOW5 files to POD5 format.
The input can be a list of SLOW5/BLOW5 files, a directory containing multiple SLOW5/BLOW5 files, or a list of directories. If a directory is provided, the tool recursively searches within for SLOW5/BLOW5 files (.slow5/blow5 extension) and converts them to POD5.
Note: Before converting a SLOW5 file having multiple read groups, split the file into groups using slow5tools `split`.

*   `-d, --out-dir STR`:<br/>
    Output directory where the POD5 files will be written. Incompatible with `-o`. If a name is provided, a directory will be created under the current working directory. Alternatively, a valid relative or absolute path can be provided. To prevent data overwriting, the program will terminate with error if the directory name already exists and is non-empty.
*  `-o FILE`, `--output FILE`:<br/>
    Outputs data to FILE and FILE must have .pod5 extension.  Incompatible with `-d`.
*  `-p, --iop INT`:<br/>
    Specifies the number of I/O processes to use during conversion of multiple files [default value: 4]. Increasing the number of I/O processes makes s2p significantly faster, especially on HPC with RAID systems (multiple disks) where a large value number of processes can be used (e.g., `-p 64`).
*  `--retain`:<br/>
	Retain the same directory structure in the converted output as the input.
*  `-h, --help`:<br/>
   Prints the help menu.


## GLOBAL OPTIONS

*  `-h, --help`:<br/>
    Prints the help menu.
*  `-V, --version`:<br/>
    Print the blue-crab version number.
*  `-v, --verbose`:<br/>
    Verbose output [v/vv/vvv] (default: 0)
*  `--profile`:<br/>
    Run cProfile on all processes - for profiling benchmarks [default value: False].


## Handling of processing/threading

Both `p2s` and `s2p` have 3 workflows depending on the file input/output

1. s2s - single to single
2. m2s - multi to single
3. m2m - multi to multi

For `p2s`

1. Single pod5 to single slow5/blow5 - Using 1 process in blue-crab, it will use the default threading model from the pod5/arrow library to read the pod5 file. When writing the slow5 file, records will accumulate into a batch of `-K, --batchsize` size and will use `-t, --threads` number of threads to compress and write that batch to the slow5/blow5 file.
2. Mutliple pod5 files to a single slow5/blow5 - Using 1 single process in blue-carb, it will use the default threading model from the pod5/arrow library to read each pod5 file, 1 at a time. When writing the slow5 file, records will accumulate into a batch of `-K, --batchsize` size and will use `-t, --threads` number of threads to compress and write that batch to the slow5/blow5 file. (use `m2m` with a `slow5tools merge` for better performance)
3. Multiple pod5 to multiple slow5/blow5 - Using multiple processes in blue-crab `-p, --iop`, it will open 1 pod5 file per process, and read that file with the default threading model from the pod5/arrow library. It will then open a slow5/blow5 file. When writing the slow5 file, records will accumulate into a batch of `-K, --batchsize` size and will use `-t, --threads` number of threads to compress and write that batch to the slow5/blow5 file. This means each process will take 1 pod5 file and convert it to a slow5/blow5. If a single monolithic slow5/blow5 file is required after this step, a `slow5tools merge` can be used to combine the multiple files.

For `s2p`

1. Single slow5/blow5 to single pod5 - Using 1 process in blue-crab, it will read the slow5/blow5 using 1 thread, and write to a pod5 file using the default threading model from the pod5/arrow library.
2. Multiple slow5/blow5 files to a single pod5 - Using 1 process in blue-crab, it will read each slow5/blow5 using 1 thread, and write to a pod5 file using the default threading model from the pod5/arrow library.
3. Multiple slow5/blow5 files to multiple pod5 - Using multiple processes in blue-crab `-p, --iop`, it will open 1 slow5/blow5 file per process, and read that file with a single thread. It will then write to a pod5 file using the default threading model from the pod5/arrow library. In effect, converting 1 slow5/blow5 file to 1 pod5 within each process.

Better read/write performance can be attained using `zstd` compression in the slow5/blow5 files.