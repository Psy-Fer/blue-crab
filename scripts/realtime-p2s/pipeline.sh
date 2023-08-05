#!/bin/bash

TMP_FILE="attempted_list.log"
TMP_FAILED="failed_list.log"
# terminate script
die() {
	echo -e "$1" >&2
	echo
	exit 1
}

LOG=start_end_trace.log

# MAX_PROC=$(nproc)
# MAX_PROC=$(echo "${MAX_PROC}/2" | bc)
MAX_PROC=1

# Colour codes for printing
YELLOW="\e[33m"
RED="\e[31m"
NORMAL="\033[0;39m"

## Handle flags
while getopts "d:l:f:p:" o; do
    case "${o}" in
        d)
            TMP_FILE=${OPTARG}
            ;;
		l)
            LOG=${OPTARG}
			;;
        f)
            TMP_FAILED=${OPTARG}
            ;;
        p)
            MAX_PROC=${OPTARG}
            ;;
        *)
            echo "[pipeline.sh] Incorrect args"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

$SLOW5TOOLS --version &> /dev/null || die $RED"[pipeline.sh] slow5tools not found in path. Exiting."$NORMAL
$BLUECRAB --version &> /dev/null || die $RED"[pipeline.sh] bluecrab not found in path. Exiting."$NORMAL

echo "[pipeline.sh] Starting pipeline with $MAX_PROC max processes"
#test -e ${LOG}  && rm ${LOG}
counter=0
while read FILE
do
(
    P5_FILEPATH=$FILE # first argument
    P5_DIR=${P5_FILEPATH%/*} # strip filename from .pod5 filepath
    PARENT_DIR=${P5_DIR%/*} # get folder one heirarchy higher
    # name of the .pod5 file (strip the path and get only the name with extension)
    P5_FILENAME=$(basename $P5_FILEPATH)
    # name of the .pod5 file without the extension
    P5_PREFIX=${P5_FILENAME%.*}

    # deduce the directory for slow5 files
    if [[ "$P5_DIR" =~ .*"pod5_pass".* ]]; then
        SLOW5_DIR=$(echo $P5_DIR | sed 's/pod5_pass/slow5_pass/g')
        SLOW5_LOG_DIR=$(echo $P5_DIR | sed 's/pod5_pass/slow5_pass_logs/g')
    elif [[ "$P5_DIR" =~ .*"pod5_fail".* ]]; then
        SLOW5_DIR=$(echo $P5_DIR | sed 's/pod5_fail/slow5_fail/g')
        SLOW5_LOG_DIR=$(echo $P5_DIR | sed 's/pod5_fail/slow5_fail_logs/g')
    elif [[ "$P5_DIR" =~ .*"pod5_skip".* ]]; then
        SLOW5_DIR=$(echo $P5_DIR | sed 's/pod5_skip/slow5_skip/g')
        SLOW5_LOG_DIR=$(echo $P5_DIR | sed 's/pod5_skip/slow5_skip_logs/g')
    else
        SLOW5_DIR=$PARENT_DIR/slow5/
        SLOW5_LOG_DIR=$PARENT_DIR/slow5_logs/
    fi
    if [ -z "$SLOW5_DIR" ] || [ -z "$SLOW5_LOG_DIR" ] ; then
        SLOW5_DIR=$PARENT_DIR/slow5/
        SLOW5_LOG_DIR=$PARENT_DIR/slow5_logs/
    fi

    test -d $SLOW5_DIR/ || { mkdir -p $SLOW5_DIR/; echo "[pipeline.sh] Created $SLOW5_DIR/. Converted SLOW5 files will be here."; }
    test -d $SLOW5_LOG_DIR/ || { mkdir -p $SLOW5_LOG_DIR/; echo "[pipeline.sh] Created $SLOW5_LOG_DIR/. SLOW5 individual logs for each conversion will be here."; }

    SLOW5_FILEPATH=$SLOW5_DIR/$P5_PREFIX.blow5
    LOG_FILEPATH=$SLOW5_LOG_DIR/$P5_PREFIX.log

    START_TIME=$(date)
    echo "[pipeline.sh::${START_TIME}]  Converting $FILE to $SLOW5_FILEPATH"
    test -e $SLOW5_FILEPATH &&  { echo -e $RED"$SLOW5_FILEPATH already exists. Converting $FILE to $SLOW5_FILEPATH failed."$NORMAL; echo $FILE >> $TMP_FAILED; }
    if ${BLUECRAB} p2s -p1 $FILE -o $SLOW5_FILEPATH 2> $LOG_FILEPATH
    then
        END_TIME=$(date)
        echo "[pipeline.sh::${END_TIME}]  Finished converting $FILE to $SLOW5_FILEPATH"
    else
        echo -e $RED"Converting $FILE to $SLOW5_FILEPATH failed. Please check log at $LOG_FILEPATH"$NORMAL
        echo $FILE >> $TMP_FAILED;
    fi

    echo "[pipeline.sh] $P5_FILEPATH" >> $TMP_FILE
    echo -e "${P5_FILEPATH}\t${SLOW5_FILEPATH}\t${START_TIME}\t${END_TIME}" >> ${LOG}
)&
    ((counter++))
    if [ $counter -ge $MAX_PROC ]; then
        echo "[pipeline.sh] Waiting for $counter jobs to finish."
        wait
        counter=0
    fi
done
wait
