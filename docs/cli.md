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

*  `-d, --out-dir STR`:<br/>
   Specifies name/location of the output directory (required option unless converting only one POD5 file). If a name is provided, a directory will be created under the current working directory. Alternatively, a valid relative or absolute path can be provided. To prevent data overwriting, the program will terminate with error if the directory name already exists and is non-empty.
*  `-o, --output FILE`:<br/>
   When only one POD5 file is being converted, `-o` specifies a single FILE to which output data is written [default value: stdout]. Incompatible with `-d` and can automatically detect the output format from the file extension.
*  `-c, --compress compression_type`:<br/>
   Specifies the compression method used for BLOW5 output. `compression_type` can be `none` for uncompressed binary; `zlib` for zlib-based (also known as gzip or DEFLATE) compression; or `zstd` for Z-standard-based compression [default value: zlib]. This option is only valid for BLOW5. `zstd` will only function if blue-crab has been built with zstd support which is turned off by default.
*  `-s, --sig-compress compression_type`:<br/>
   Specifies the raw signal compression method used for BLOW5 output. `compression_type` can be `none` for uncompressed raw signal or `svb-zd` to compress the raw signal using StreamVByte zig-zag delta [default value: svb-zd]. This option is introduced from blue-crab v0.3.0 onwards. Note that record compression (-c option above) is still applied on top of the compressed signal. Signal compression with svb-zd and record compression with zstd is similar to ONT's vbz.  zstd+svb-zd offers slightly smaller file size and slightly better performance compared to the default zlib+svb-zd, however, will be less portable.
*  `-p, --iop INT`:<br/>
    Specifies the number of I/O processes to use during conversion [default value: 4]. Increasing the number of I/O processes makes p2s significantly faster, especially on HPC with RAID systems (multiple disks) where a large value number of processes can be used (e.g., `-p 64`).
* `-t, --threads INT`:<br/>
    Number of threads used for encoding S/BLOW5 records [default value: 8].
* `-K, --batchsize`:<br/>
    The batch size used for encoding S/BLOW5 records. This is the number of S/BLWO5 records on the memory at once [default value: 1000]. An increased batch size improves multi-threaded performance at cost of higher RAM.
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
Note: Before converting a SLOW5 file having multiple read groups, split the file into groups using `split`.

*   `-d, --out-dir STR`:<br/>
    Output directory where the POD5 files will be written. If a name is provided, a directory will be created under the current working directory. Alternatively, a valid relative or absolute path can be provided. To prevent data overwriting, the program will terminate with error if the directory name already exists and is non-empty.
*  `-o FILE`, `--output FILE`:<br/>
    Outputs data to FILE and FILE must have .pod5 extension.
*  `-p, --iop INT`:<br/>
    Specifies the number of I/O processes to use during conversion [default value: 8]. Increasing the number of I/O processes makes p2s significantly faster, especially on HPC with RAID systems (multiple disks) where a large value number of processes can be used (e.g., `-p 64`).
* `-t, --threads INT`:<br/>
    Number of threads used for decoding S/BLOW5 records [default value: 8].
* `-K, --batchsize`:<br/>
    The batch size used for decoding S/BLOW5 records. This is the number of S/BLOW5 records on the memory at once [default value: 1000]. An increased batch size improves multi-threaded performance at cost of higher RAM.
*  `-h, --help`:<br/>
   Prints the help menu.


## GLOBAL OPTIONS

*  `-h, --help`:<br/>
    Prints the help menu.
*  `-V, --version`:<br/>
    Print the blue-crab version number.
* `--profile:<br/>
    Run cProfile on all processes - for profiling benchmarks [default value: False].	