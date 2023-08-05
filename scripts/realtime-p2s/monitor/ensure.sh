#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    monitor.sh [options ...] [pod5_dir]  | ${SCRIPT_NAME} -
#%
#% DESCRIPTION
#%    Ensures corresponding pod5 are created
#%    before printing pod5 filename.
#%
#% OPTIONS
#%    -h                                 Print help message
#%    -i                                 Print script information
#%    -r                                 Check if dev files already contain any of the filenames
#%    -d [tmp_file]                      Specify the temporary file location for resuming purposes.
#%                                       Only used when resume option set.
#%    -l [log_file]                      Specify the log file location for tracing
#%
#================================================================
#- IMPLEMENTATION
#-    authors         Sasha JENNER (jenner.sasha@gmail.com)
#-    license         MIT
#-
#-    Copyright (c) 2020 Sasha Jenner
#-
#-    Permission is hereby granted, free of charge, to any person obtaining a copy
#-    of this software and associated documentation files (the "Software"), to deal
#-    in the Software without restriction, including without limitation the rights
#-    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#-    copies of the Software, and to permit persons to whom the Software is
#-    furnished to do so, subject to the following conditions:
#-
#-    The above copyright notice and this permission notice shall be included in all
#-    copies or substantial portions of the Software.
#-
#-    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#-    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#-    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#-    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#-    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#-    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#-    SOFTWARE.
#-
#================================================================
# END_OF_HEADER
#================================================================

    #== Necessary variables ==#
SCRIPT_HEADSIZE=$(head -200 ${0} | grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"

    #== Usage functions ==#
usage() { printf "Usage: "; head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }
usagefull() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }
scriptinfo() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#-" | sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }



    #== Default variables ==#

RESUME=false # Set resume option to false by default
TMP_FILE="processed_list.log" # Default  temp in current directory
LOG="monitor_trace.log"

## Handle flags
while getopts "hird:l:" o; do
    case "${o}" in
        h)
            usagefull
            exit 0
            ;;
        i)
            scriptinfo
            exit 0
            ;;
		l)
            LOG=${OPTARG}
			;;
        d)
            TMP_FILE=${OPTARG}
            ;;
        r)
            RESUME=true
            ;;
        *)
            echo "[ensure.sh] Incorrect args"
            usagefull
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

    #== Begin ==#


# Initialise counters
i_new=0
i_old=0

# Colour codes for printing
YELLOW="\e[33m"
RED="\e[31m"
NORMAL="\033[0;39m"

#test -e ${LOG} && rm ${LOG}

while read filename; do

    if [ "$filename" = "-1" ]; then # Exit if -1 flag sent
        >&2 echo "[ensure.sh] exiting"
        exit 0
    fi

    parent_dir=${filename%/*} # Strip filename from .pod5 filepath
    grandparent_dir=${parent_dir%/*} # Strip parent directory from filepath

    pathless=$(basename $filename) # Strip path
    prefix=${pathless%.*} # Remove extension

    if echo $filename | grep -q '\.pod5$'; then # If it is a pod5 file

        if $RESUME; then # If resume option set
            grep -q "/$prefix\.pod5$" "$TMP_FILE" # Check if filename exists in temp files

            if [ $? -eq "0" ]; then # If the file has been processed
                ((i_old ++))
                >&2 echo -e "[ensure.sh] Already converted file ($i_old): $filename"
                continue # Wait for next input

            else # Else it is new
                ((i_new ++))
                >&2 echo -e "[ensure.sh] Missed file ($i_new): $filename"
            fi

        fi

        echo $filename # Output pod5 filename
        TIME=$(date)
        echo -e "[ensure.sh] "$filename"\t"${TIME} >> ${LOG}

    fi
done
