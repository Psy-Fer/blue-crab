#!/bin/bash
# Run p2s, s2p, and again p2s and check if first produced slow5s are same as the last set.
Usage1="p2s_s2p_integrity_test.sh"
Usage2="p2s_s2p_integrity_test.sh [path to pod5 directory] [path to create a temporary directory][-c or --to (optional) [clean_fscache -f (optional)]"

# Relative path to "slow5/tests/"
REL_PATH="$(dirname $0)/"

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

# terminate script
die() {
    echo -e "${RED}$1${NC}" >&2
    echo
    exit 1
}

pod5_DIR="$REL_PATH/data/raw/p2s_s2p_integrity/"
TEMP_DIR="$REL_PATH/data/out/p2s_s2p_integrity/"
if [[ "$#" -ge 2 ]]; then
  pod5_DIR=$1
  TEMP_DIR="$2/p2s_s2p_integrity_test"
fi

p2s_atm1_OUTPUT="$TEMP_DIR/p2s_attempt1"
s2p_OUTPUT="$TEMP_DIR/s2p"
p2s_atm2_OUTPUT="$TEMP_DIR/p2s_attempt2"

SLOW5_FORMAT="--to slow5"
if [[ "$#" -eq 4 ]]; then
    SLOW5_FORMAT=$4
fi

test -d "$TEMP_DIR" && rm -r "$TEMP_DIR"
mkdir "$TEMP_DIR" || die "Creating $TEMP_DIR failed"
mkdir "$p2s_atm1_OUTPUT" || die "Creating $p2s_atm1_OUTPUT failed"
mkdir "$s2p_OUTPUT" || die "Creating $s2p_OUTPUT failed"
mkdir "$p2s_atm2_OUTPUT" || die "Creating $p2s_atm2_OUTPUT failed"


if [[ $* == *-f* ]];then
  clean_fscache
fi
echo "-------------------p2s attempt 1-------------------"
echo
blue-crab p2s "$pod5_DIR" -d "$p2s_atm1_OUTPUT" --iop 64 $SLOW5_FORMAT 2>/dev/null || die "p2s attempt 1 failed"
if [[ $* == *-f* ]];then
  clean_fscache
fi
echo
echo "-------------------s2p attempt-------------------"
echo
blue-crab s2p "$p2s_atm1_OUTPUT" -d "$s2p_OUTPUT" --iop 64 2>/dev/null || die "s2p failed"
if [[ $* == *-f* ]];then
  clean_fscache
fi
echo
echo "-------------------p2s attempt 2-------------------"
echo
blue-crab p2s "$s2p_OUTPUT" -d "$p2s_atm2_OUTPUT" --iop 64 $SLOW5_FORMAT 2>/dev/null || die "p2s attempt 2 failed"
echo "running diff on p2s attempt 1 and p2s attempt 2"
echo "du -hs $p2s_atm1_OUTPUT"
du -hs "$p2s_atm1_OUTPUT"
echo "du -hs $p2s_atm2_OUTPUT"
du -hs "$p2s_atm2_OUTPUT"
echo "ls $p2s_atm1_OUTPUT | wc"
ls "$p2s_atm1_OUTPUT" | wc
echo "ls $p2s_atm2_OUTPUT | wc"
ls "$p2s_atm2_OUTPUT" | wc
echo "p2s might not create the same exact header lines (starting with '@') from after s2p pod5s"
echo "Running diff only on lines starting with '@'. If there are no differences the following line is blank"
diff --ignore-matching-lines=?@ "$p2s_atm1_OUTPUT" "$p2s_atm2_OUTPUT"
echo
echo "Again running diff (ignoring header lines starting with '@'"
diff --ignore-matching-lines=@ "$p2s_atm1_OUTPUT" "$p2s_atm2_OUTPUT" > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS: p2s and s2p conversions are consistent!${NC}"
elif [ $? -eq 1 ]; then
    echo -e "${RED}FAILURE: p2s and s2p conversions are not consistent${NC}"
    exit 1
else
    echo -e "${RED}ERROR: diff failed for some weird reason${NC}"
    exit 1
fi

rm -r "$TEMP_DIR" || die "Removing $TEMP_DIR failed"

exit 0