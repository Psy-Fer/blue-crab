#!/bin/bash
# Run s2p with different file, input and output formats.
Usage="test_s2p.sh"

# Relative path to "slow5/tests/"
REL_PATH="$(dirname $0)/"

RED='\033[0;31m' ; GREEN='\033[0;32m' ; NC='\033[0m' # No Color

# terminate script
die() {
    echo -e "${RED}$1${NC}" 1>&3 2>&4
    echo
    exit 1
}
#redirect
verbose=0
exec 3>&1
exec 4>&2
if ((verbose)); then
  echo "verbose=1"
else
  echo "verbose=0"
  exec 1>/dev/null
  exec 2>/dev/null
fi
#echo "this should be seen if verbose"
#echo "this should always be seen" 1>&3 2>&4
RAW_DIR=$REL_PATH/data/raw/s2p
EXP_SLOW5_DIR=$REL_PATH/data/exp/s2p

OUTPUT_DIR="$REL_PATH/data/out/s2p"
test -d  $OUTPUT_DIR && rm -r "$OUTPUT_DIR"
mkdir "$OUTPUT_DIR" || die "Creating $OUTPUT_DIR failed"


echo "-------------------blue-crab version-------------------"
blue-crab --version || die "blue-crab version failed"
echo

TESTCASE_NO=1
TESTNAME=".slow5 to .pod5"
echo "-------------------testcase:$TESTCASE_NO: $TESTNAME-------------------"
blue-crab s2p $RAW_DIR/a.slow5 -o $OUTPUT_DIR/a.pod5 || die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=2
TESTNAME=".slow5 to .pod5 (output directory given)"
echo "-------------------testcase:$TESTCASE_NO: $TESTNAME-------------------"
blue-crab s2p $RAW_DIR/a.slow5 -d $OUTPUT_DIR/a || die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=3
TESTNAME=".slow5 (in current directory) to .pod5"
echo "-------------------testcase:$TESTCASE_NO: $TESTNAME-------------------"
cd $RAW_DIR
CD_BACK=../../../..
$CD_BACK/blue-crab s2p a.slow5 -o $CD_BACK/$OUTPUT_DIR/b.pod5 || die "testcase $TESTCASE_NO failed"
cd $CD_BACK
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4
TESTNAME=".slow5 (in current directory) to .pod5 (output directory given)"
echo "-------------------testcase:$TESTCASE_NO: $TESTNAME-------------------"
cd $RAW_DIR
CD_BACK=../../../..
$CD_BACK/blue-crab s2p a.slow5 -d $CD_BACK/$OUTPUT_DIR/b || die "testcase $TESTCASE_NO failed"
cd $CD_BACK
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

rm -r $OUTPUT_DIR || die "Removing $OUTPUT_DIR failed"

exit 0