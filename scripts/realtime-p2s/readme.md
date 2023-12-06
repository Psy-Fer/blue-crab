# Real-time POD5 to SLOW5 conversion

This can be used on your computer where you are doing the sequencing acquisition, for instance, the laptop connected to the MinION and running MinKNOW.

## Pre-requisites
- inotify-tools:  On Ubuntu `sudo apt install inotify-tools`
- slow5tools in the path or `SLOW5TOOLS` environment variable set to the slow5tools location.
- blue-crab in the path or `BLUECRAB` environment variable set to the blue-crab location.

## Limitations
- Only tested for Linux at the moment (does not work on mounted directories in WSL due to its [inotify limitations](https://github.com/microsoft/WSL/issues/4739)).


## Real run

Assume your sequencing data directory is */data* and you are sequencing an experiment called *my_sequencing_experiment* on to */data/my_sequencing_experiment*. Simply run the following for real-time POD5 to SLOW5 conversion.

```
./realp2s.sh -m /data/my_sequencing_experiment
```

This script will monitor the specified directory */data/my_sequencing_experiment* and as soon as a newly generated *POD5* is found, it will convert it. The converted slow5 files will be under */data/my_sequencing_experiment/parent_dir_of_pod5/slow5* and the individual logs from each slow5 conversion will be under */data/my_sequencing_experiment/parent_dir_of_pod5/slow5_logs*.

Brief log messages (including any conversion failures) are written to the terminal as well as */data/my_sequencing_experiment/realtime_p2s.log*. The list of files that were detected by the monitor and which the conversion was attempted will be written to */data/my_sequencing_experiment/realtime_p2s_attempted_list.log*. If any conversion fails, the names of the *POD5* files will be written to *realtime_p2s_failed_list.log*. In addition, there will be some other debug/trace logs (e.g.,*realtime_p2s_monitor_trace.log*).

The monitoring script will terminate if it idles for 6 hours, i.e., no new POD5 files were created under */data/my_sequencing_experiment/*, the script will terminate assuming that the sequencing run has been completed. Just before termination, the script will check for any leftover POD5 and will convert them if present. Also, it will do a brief check on the file count and print some statistics any warnings if any. If you want to make the script terminate as soon as the sequencing run in MinKNOW stops, please add `export REALP2S_AUTO=1` to your `~/.bashrc` (before running realp2s.sh and remember to source the .bashrc). Note that this auto-terminate feature relies on the "final_summary*.txt" file created by MinKNOW and will not be effective if ONT changes that.

If you want to resume a conversion that was abruptly terminated halfway, use the `-r` option for resuming as below:

```
./realp2s.sh -m /data/my_sequencing_experiment -r
```

### Options

* `-m STR`:
    The sequencing experiment directory to be monitored. This is usually where MinKNOW writes data for your experiment e.g., */data/my_sequencing_experiment/* or */var/lib/minknow/data/my_sequencing_experiment/*.
* `-r`:
    Resumes a previous live conversion. This option is useful if the real-time conversion abruptly stops in the middle and you now want to resume the live conversion.
* `-t INT`:
    Timeout in seconds [default: 21600]. The script will end if no new POD5 is written for this specified period of time.
* `-p INT`:
    Maximum number of parallel conversion processes [default: 1]. This value can be increased to keep up with the sequencing rate as necessary, depending on the number of CPU cores available.

### Environment variables

The following optional environment variables will be honoured by the real-time conversion script if they are set.

- REALP2S_AUTO: make the script terminate as soon as the sequencing run in MinKNOW stops as explained above.
- SLOW5TOOLS: path to the slow5tools binary
- BLUECRAB: path to the blue-crab [launcher script](../../README.md#optional-wrapper-script-and-adding-to-path)

## Simulation

Say you have some POD5 files in a directory at */data2/previous_run*. You can test our real-time conversion script (*realp2s.sh*) by simulating a run based on these existing POD5 files (*monitor/simulator.sh*).

First create a directory to represent our simulated sequencing run, for instance, `mkdir /data/my_simulated_run`.
Now launch the real-time conversion script to monitor this directory for newly created POD5.

```
./realp2s.sh -m /data/my_simulated_run
```

Take another terminal and launch the simulator now.
```
monitor/simulator.sh /data2/previous_run /data/my_simulated_run
```

*monitor/simulator.sh* will copy POD5 files from */data2/previous_run* to */data/my_simulated_run/pod5*, one at a time at a default interval of 10 seconds. *realp2s.sh* will monitor the */data/my_simulated_run/* and will convert newly created pod5 files. You should see the converted slow5 file under */data/my_simulated_run/slow5*.
