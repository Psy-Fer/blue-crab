#!/bin/bash
# Run p2s with different file, input and output formats.
Usage="test_p2s.sh"

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

OUTPUT_DIR="$REL_PATH/data/out/p2s"
test -d  $OUTPUT_DIR && rm -r "$OUTPUT_DIR"
mkdir "$OUTPUT_DIR" || die "Creating $OUTPUT_DIR failed"

POD5_DIR=$REL_PATH/data/raw/p2s
EXP_SLOW5_DIR=$REL_PATH/data/exp/p2s

echo "-------------------blue-crab version-------------------"
blue-crab --version || die "blue-crab version failed"
echo

#### Single process tests

TESTCASE_NO=1.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:single_process output:stdout-------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 --iop 1 --to slow5 > $OUTPUT_DIR/stdout.slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/stdout.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.2
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:single_process output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 -d $OUTPUT_DIR/pod5-output --iop 1 --to slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/pod5-output/0.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.3
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:stdout-------------------"
blue-crab p2s $POD5_DIR/pod5 --iop 1 --to slow5 > $OUTPUT_DIR/stdout.slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/directory_pod5.slow5 $OUTPUT_DIR/stdout.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


echo
rm $OUTPUT_DIR/pod5/*
TESTCASE_NO=1.4
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5 --iop 1 --to slow5 -d $OUTPUT_DIR/pod5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/ssm1.slow5 $OUTPUT_DIR/pod5/ssm1.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/ssm2.slow5 $OUTPUT_DIR/pod5/ssm2.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/ssm3.slow5 $OUTPUT_DIR/pod5/ssm3.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.5
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: stdout-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
$CD_BACK/blue-crab p2s ssm1.pod5 --iop 1 --to slow5 > $CD_BACK/$OUTPUT_DIR/stdout.slow5 || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


# ----------------------------------------------- multi process --------------------------------------------

echo
rm $OUTPUT_DIR/pod5-output/*
TESTCASE_NO=2.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:multi output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 -d $OUTPUT_DIR/pod5-output --iop 4 --to slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/pod5-output/0.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:multi output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
rm $OUTPUT_DIR/pod5-output/*
TESTCASE_NO=2.2
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:multi output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5 -d $OUTPUT_DIR/pod5-output --iop 4 --to slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/pod5-output/0.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:multi output"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/pod5-output/1.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:multi output"
diff -q $EXP_SLOW5_DIR/pod5-output/a_pod5.slow5 $OUTPUT_DIR/pod5-output/2.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:multi output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4



#----------------------------------------- run id conflicts -------------------------------------------

echo
TESTCASE_NO=3.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:stdout run_id_conflicts-------------------"
blue-crab p2s $POD5_DIR/run_id_conflicts/multi_pod5 --iop 1 --to slow5 > $OUTPUT_DIR/stdout.slow5 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


## Output formats

TESTCASE_NO=4.1
echo "------------------- p2s testcase $TESTCASE_NO >>> blow5 zlib output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 -o $OUTPUT_DIR/ssm1.blow5  -c zlib -s none
diff $EXP_SLOW5_DIR/pod5-output/ssm1_zlib.blow5 $OUTPUT_DIR/ssm1.blow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for blow zlib out"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.2
echo "------------------- p2s testcase $TESTCASE_NO >>> blow5 zlib-svb output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 -o $OUTPUT_DIR/ssm1.blow5 -c zlib -s svb-zd
diff $EXP_SLOW5_DIR/pod5-output/ssm1_zlib_svb.blow5  $OUTPUT_DIR/ssm1.blow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for blow zlib-svb out"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.3
echo "------------------- p2s testcase $TESTCASE_NO >>> slow5 output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 -o $OUTPUT_DIR/ssm1.slow5
diff $EXP_SLOW5_DIR/pod5-output/ssm1.slow5  $OUTPUT_DIR/ssm1.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for slow5"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


TESTCASE_NO=4.4
echo "------------------- p2s testcase $TESTCASE_NO >>> blow5 zlib-svb output to stdout-------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 --to blow5 -c zlib -s svb-zd > $OUTPUT_DIR/ssm1.blow5
diff $EXP_SLOW5_DIR/pod5-output/ssm1_zlib_svb.blow5 $OUTPUT_DIR/ssm1.blow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for blow zlib out"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.5
echo "------------------- p2s testcase $TESTCASE_NO >>> slow5 output to stdout-------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 --to slow5  > $OUTPUT_DIR/ssm1.slow5
diff $EXP_SLOW5_DIR/pod5-output/ssm1.slow5 $OUTPUT_DIR/ssm1.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for slow5"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.6
echo "------------------- p2s testcase $TESTCASE_NO >>> output extension and --to mismatch -------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 --to slow5  -o $OUTPUT_DIR/ssm1.blow5 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.7
echo "------------------- p2s testcase $TESTCASE_NO >>> compression requested with slow5 -------------------"
blue-crab p2s $POD5_DIR/pod5/ssm1.pod5 --to slow5  -c zlib $OUTPUT_DIR/err.slow5 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.8
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: file-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
$CD_BACK/blue-crab p2s ssm1.pod5 --iop 1 --to slow5 -o $CD_BACK/$OUTPUT_DIR/$TESTCASE_NO.slow5 || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.9
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: directory-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
$CD_BACK/blue-crab -v 7 p2s ssm1.pod5 --iop 1 --to slow5 -d $CD_BACK/$OUTPUT_DIR/$TESTCASE_NO || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


echo
TESTCASE_NO=4.10
echo "------------------- p2s testcase $TESTCASE_NO >>> retain_dir_structure without --retain failure expected -------------------"
blue-crab p2s $POD5_DIR/retain_dir_structure -d $OUTPUT_DIR/retain_dir_structure && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.11
echo "------------------- p2s testcase $TESTCASE_NO >>> retain_dir_structure-------------------"
blue-crab p2s $POD5_DIR/retain_dir_structure -d $OUTPUT_DIR/retain_dir_structure --retain || die "testcase $TESTCASE_NO failed"
diff $EXP_SLOW5_DIR/retain_dir_structure  $OUTPUT_DIR/retain_dir_structure > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.12
echo "------------------- p2s testcase $TESTCASE_NO >>> duplicate file name -------------------"
blue-crab p2s $POD5_DIR/pod5/ $POD5_DIR/pod5/ -d $OUTPUT_DIR/dupli 2> $OUTPUT_DIR/err.log && die "testcase $TESTCASE_NO failed"
grep -q "ERROR.* Two or more pod5 files have the same filename.*" $OUTPUT_DIR/err.log || die "ERROR: p2s_test testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


rm -r $OUTPUT_DIR || die "Removing $OUTPUT_DIR failed"

exit 0
