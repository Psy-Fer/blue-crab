#!/bin/bash

# MIT License

# Copyright (c) 2020 Hiruna Samarakoon
# Copyright (c) 2020 Sasha Jenner
# Copyright (c) 2020,2023 Hasindu Gamaarachchi

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
verbose=1
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
mkdir -p "$OUTPUT_DIR" || die "Creating $OUTPUT_DIR failed"

POD5_DIR=$REL_PATH/data/raw/p2s
EXP_SLOW5_DIR=$REL_PATH/data/exp/p2s

echo "-------------------blue-crab version-------------------"
blue-crab --version || die "blue-crab version failed"
echo

#### Single process tests

TESTCASE_NO=1.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file 4khz process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/b/b1.pod5 --iop 1 -o $OUTPUT_DIR/out.slow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/b1.slow5 $OUTPUT_DIR/out.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=1.2
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file 5khz process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 --iop 1 -o $OUTPUT_DIR/out.blow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/out.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=1.3
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file 5khz process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z2.pod5 --iop 1 -o $OUTPUT_DIR/out.blow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/out.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.4
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:single_process output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 -d $OUTPUT_DIR/pod5-output --iop 1 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5-output/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.5
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:single_process output:empty existing directory-------------------"
rm $OUTPUT_DIR/pod5-output/*
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 -d $OUTPUT_DIR/pod5-output --iop 1 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5-output/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.6
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:single_process output:overwrite non empty directory-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 -d $OUTPUT_DIR/pod5-output --iop 1 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.7
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z --iop 1 -o $OUTPUT_DIR/out.blow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/directory_z.blow5 $OUTPUT_DIR/out.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
rm -rf $OUTPUT_DIR/pod5
TESTCASE_NO=1.8
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5 --iop 1 -d $OUTPUT_DIR/pod5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/pod5/z2.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/b1.blow5 $OUTPUT_DIR/pod5/b1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.9
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:multiple files process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 $POD5_DIR/pod5/z/z2.pod5  --iop 1 -o $OUTPUT_DIR/out.blow5 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/directory_z.blow5 $OUTPUT_DIR/out.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'p2s format:pod5 input:directory process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
rm -rf $OUTPUT_DIR/pod5
TESTCASE_NO=1.10
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:multiple directory process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z/ $POD5_DIR/pod5/b/ --iop 1 -d $OUTPUT_DIR/pod5/ || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/pod5/z2.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/b1.blow5 $OUTPUT_DIR/pod5/b1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


echo
rm -rf $OUTPUT_DIR/pod5
TESTCASE_NO=1.11
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory and file process:single_process output:file-------------------"
blue-crab p2s $POD5_DIR/pod5/z/ $POD5_DIR/pod5/b/b1.pod5 --iop 1 -d $OUTPUT_DIR/pod5/ || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/pod5/z2.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/b1.blow5 $OUTPUT_DIR/pod5/b1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=1.12
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: out-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
blue-crab p2s z/z1.pod5 --iop 1 -o $CD_BACK/$OUTPUT_DIR/out.blow5 || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


# ----------------------------------------------- multi process and threads --------------------------------------------

echo
rm -f $OUTPUT_DIR/pod5-output/*
TESTCASE_NO=2.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:multi output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 -d $OUTPUT_DIR/pod5-output -p 4 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5-output/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:multi output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


echo
rm -f $OUTPUT_DIR/pod5-output/*
TESTCASE_NO=2.2
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:file process:multi output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5/z/z1.pod5 -d $OUTPUT_DIR/pod5-output -t 4 || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5-output/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:multi output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
rm $OUTPUT_DIR/pod5-output/*
TESTCASE_NO=2.3
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:multi output:directory-------------------"
blue-crab p2s $POD5_DIR/pod5 -d $OUTPUT_DIR/pod5-output --iop 4  || die "testcase $TESTCASE_NO failed"
diff -q $EXP_SLOW5_DIR/pod5-output/z1.blow5 $OUTPUT_DIR/pod5/z1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/pod5/z2.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
diff -q $EXP_SLOW5_DIR/pod5-output/b1.blow5 $OUTPUT_DIR/pod5/b1.blow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for 'format:pod5 input:file process:single_process output"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4



#----------------------------------------- run id conflicts -------------------------------------------

echo
TESTCASE_NO=3.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:directory process:single_process output:out run_id_conflicts-------------------"
blue-crab p2s $POD5_DIR/pod5 --iop 1 -o $OUTPUT_DIR/out.blow5 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4
echo

echo
TESTCASE_NO=3.1
echo "------------------- p2s testcase $TESTCASE_NO: format:pod5 input:multigroup file process:single_process output:out run_id_conflicts-------------------"
blue-crab p2s $POD5_DIR/unsupported/ --iop 1 -o $OUTPUT_DIR/out.blow5 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4
echo


## Output formats

TESTCASE_NO=4.1
echo "------------------- p2s testcase $TESTCASE_NO >>> blow5 zlib output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/z/z2.pod5  -o $OUTPUT_DIR/pod5-output/z2.blow5  -c zlib -s none
diff $EXP_SLOW5_DIR/pod5-output/z2_zlib.blow5 $OUTPUT_DIR/pod5-output/z2.blow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for blow zlib out"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.2
echo "------------------- p2s testcase $TESTCASE_NO >>> blow5 zlib-svb output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/z/z2.pod5  -o $OUTPUT_DIR/pod5-output/z2.blow5 -c zlib -s svb-zd
diff $EXP_SLOW5_DIR/pod5-output/z2.blow5 $OUTPUT_DIR/pod5-output/z2.blow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for blow zlib-svb out"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.3
echo "------------------- p2s testcase $TESTCASE_NO >>> slow5 output using -o -------------------"
blue-crab p2s $POD5_DIR/pod5/b/b1.pod5 -o $OUTPUT_DIR/pod5-output/b1.blow5
diff $EXP_SLOW5_DIR/pod5-output/b1.blow5 $OUTPUT_DIR/pod5-output/b1.blow5> /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for slow5"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.4
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: file-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
blue-crab p2s z/z1.pod5 --iop 1 -o $CD_BACK/$OUTPUT_DIR/$TESTCASE_NO.slow5 || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.5
echo "------------------- p2s testcase $TESTCASE_NO >>> current directory:pod5 file directory output: directory-------------------"
cd $POD5_DIR/pod5
CD_BACK=../../../../..
blue-crab -vv p2s z/z1.pod5  --iop 1 -d $CD_BACK/$OUTPUT_DIR/$TESTCASE_NO || die "testcase $TESTCASE_NO failed"
cd -
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.6
echo "------------------- p2s testcase $TESTCASE_NO >>> retain_dir_structure without --retain failure expected -------------------"
blue-crab p2s $POD5_DIR/retain_dir_structure -d $OUTPUT_DIR/retain_dir_structure && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.7
echo "------------------- p2s testcase $TESTCASE_NO >>> retain_dir_structure-------------------"
blue-crab p2s $POD5_DIR/retain_dir_structure -d $OUTPUT_DIR/retain_dir_structure --retain || die "testcase $TESTCASE_NO failed"
diff -r $EXP_SLOW5_DIR/retain_dir_structure  $OUTPUT_DIR/retain_dir_structure > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=4.8
echo "------------------- p2s testcase $TESTCASE_NO >>> duplicate file name -------------------"
blue-crab p2s $POD5_DIR/pod5/b/ $POD5_DIR/pod5/b/ -d $OUTPUT_DIR/dupli 2> $OUTPUT_DIR/err.log && die "testcase $TESTCASE_NO failed"
grep -q "ERROR.* File name duplicates present.*" $OUTPUT_DIR/err.log || die "ERROR: p2s_test testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

echo
TESTCASE_NO=4.10
echo "------------------- p2s testcase $TESTCASE_NO >>> Multiple dircetories to --retain failure expected -------------------"
blue-crab p2s $POD5_DIR/retain_dir_structure $POD5_DIR/pod5/b/  -d $OUTPUT_DIR/retain_dir_structure --retain  && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

########################## Stupid end reason ####################


# TESTCASE_NO=5.1
# echo "------------------- p2s testcase $TESTCASE_NO >>> end_reason pod5-------------------"
# mkdir -p $OUTPUT_DIR/end_reason_pod5 || die "creating $OUTPUT_DIR/end_reason_pod5 failed"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason0.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason0.slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason0.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason0.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


# TESTCASE_NO=5.2
# echo "------------------- p2s testcase $TESTCASE_NO >>> end_reason datatype is uint8_t-------------------"
# mkdir -p $OUTPUT_DIR/end_reason_pod5 || die "creating $OUTPUT_DIR/end_reason_pod5 failed"
# LOG=$OUTPUT_DIR/end_reason_pod5/err.log
# #blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_datatype_uint8_t.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_datatype_uint8_t.slow5 || die "testcase $TESTCASE_NO failed"
# #diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason_datatype_uint8_t.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason_datatype_uint8_t.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_datatype_uint8_t.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_datatype_uint8_t.slow5 2> $LOG && die "testcase $TESTCASE_NO failed"
# grep -q -i "ERROR.*This is a known issue in ont_pod5_api's compress_pod5" $LOG || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4



# TESTCASE_NO=5.4
# echo "------------------- p2s testcase $TESTCASE_NO >>> end_reason datatype is string-------------------"
# LOG=$OUTPUT_DIR/end_reason_pod5/err.log
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_string.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_string.slow5 2> $LOG  && die "testcase $TESTCASE_NO failed"
# grep -q -i "ERROR.*The datatype of the attribute Raw/end_reason.*H5T_STRING instead of H5T_ENUM.* " $LOG || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=5.5
# echo "------------------- p2s testcase $TESTCASE_NO >>> end_reason datatype is int32_t-------------------"
# LOG=$OUTPUT_DIR/end_reason_pod5/err.log
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_int32.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_int32.slow5 2> $LOG  && die "testcase $TESTCASE_NO failed"
# grep -q -i "ERROR.*The datatype of the attribute Raw/end_reason.*H5T_STD_I32LE instead of H5T_ENUM.* " $LOG || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=5.6
# echo "------------------- p2s testcase $TESTCASE_NO >>> a different key label-------------------"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_differnt_key.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_differnt_key.slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason_differnt_key.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason_differnt_key.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=5.7
# echo "------------------- p2s testcase $TESTCASE_NO >>> a different order of label-------------------"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_differnt_key_order.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_differnt_key_order.slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason_differnt_key_order.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason_differnt_key_order.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=5.8
# echo "------------------- p2s testcase $TESTCASE_NO >>> a new keylabel-------------------"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason_new_key.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason_new_key.slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason_new_key.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason_new_key.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# we assume that if the run_id are the same, enum_labels are the same - so we don't test this
# also we assume that if the first read does not have the enum, the rest will not as well
# TESTCASE_NO=35
# echo "------------------- p2s testcase $TESTCASE_NO >>> end_reason found only in the second read group pod5 1-------------------"
# mkdir -p $OUTPUT_DIR/end_reason_pod5 || die "creating $OUTPUT_DIR/end_reason_pod5 failed"
# blue-crab p2s $POD5_DIR/end_reason_pod5/end_reason1.pod5 -o $OUTPUT_DIR/end_reason_pod5/end_reason1.slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/end_reason_pod5/end_reason1.slow5 $OUTPUT_DIR/end_reason_pod5/end_reason1.slow5 > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for end_reason pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


#--------------------------------------Unsupported POD5------------------------------------

#--------------------------------------Unusual POD5------------------------------------

# echo
# TESTCASE_NO=6.1
# echo "------------------- p2s testcase $TESTCASE_NO >>> auxiliary field missing pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/median_before_missing.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/median_before_missing.slow5 --to slow5 || die "testcase $TESTCASE_NO failed"
# diff -q $EXP_SLOW5_DIR/unusual_pod5/median_before_missing.slow5 $OUTPUT_DIR/unusual_pod5/median_before_missing.slow5 || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO for auxiliary field missing pod5"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# echo
# TESTCASE_NO=6.2
# echo "------------------- p2s testcase $TESTCASE_NO >>> primary field missing pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/offset_missing.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/offset_missing.slow5 --to slow5 && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# echo
# TESTCASE_NO=6.3
# echo "------------------- p2s testcase $TESTCASE_NO >>> run_id_missing_in_first_read_group_tracking_id pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/run_id_missing_in_first_read_group_tracking_id.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/run_id_missing.slow5 --to slow5 || die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.4
# echo "------------------- p2s testcase $TESTCASE_NO >>> run_id_missing_in_first_read_group_read but is in the tracking_id group pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/run_id_missing_in_first_read_group_read.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/run_id_missing.slow5 --to slow5 || die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.5
# echo "------------------- p2s testcase $TESTCASE_NO >>> run_id_missing_in_fifth_read_group_read but is in the tracking_id group pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/run_id_missing_in_fifth_read_group_read.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/run_id_missing.slow5 --to slow5 || die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.6
# echo "------------------- p2s testcase $TESTCASE_NO >>> run_id_missing_in_first_read_group_in_both_read_and_tracking_id pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/run_id_missing_in_first_read_group_in_both_read_and_tracking_id.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/run_id_missing.slow5 --to slow5 && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.7
# echo "------------------- p2s testcase $TESTCASE_NO >>> run_id_missing_in_fifth_read_group_in_both_read_and_tracking_id pod5-------------------"
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# blue-crab p2s $POD5_DIR/unusual_pod5/run_id_missing_in_fifth_read_group_in_both_read_and_tracking_id.pod5 --iop 1 -o $OUTPUT_DIR/unusual_pod5/run_id_missing.slow5 --to slow5 && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.8
# echo "------------------- p2s testcase $TESTCASE_NO >>> new non string attribute in context tags  -------------------"
# # This is a header attribute, thus should be converted to string, but with a warning
# mkdir -p $OUTPUT_DIR/unusual_pod5 || die "creating $OUTPUT_DIR/unusual_pod5 failed"
# LOG=$OUTPUT_DIR/unusual_pod5/new_attrib_in_context.log
# OUTPUT_FILE=$OUTPUT_DIR/unusual_pod5/new_attrib_in_context.slow5
# blue-crab p2s $POD5_DIR/unusual_pod5/new_attrib_in_context.pod5 -o $OUTPUT_FILE 2> $LOG  || die "testcase $TESTCASE_NO failed"
# grep -q -i "WARNING.*converting.*to string" $LOG || die "Warning in testcase $TESTCASE_NO failed"
# diff $EXP_SLOW5_DIR/unusual_pod5/new_attrib_in_context.slow5 $OUTPUT_FILE  > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.9
# echo "------------------- p2s testcase $TESTCASE_NO >>> new non string attribute in tracking id  -------------------"
# # This is a header attribute, thus should be converted to string, but with a warning
# LOG="$OUTPUT_DIR/unusual_pod5/new_attrib_in_tracking.log"
# OUTPUT_FILE=$OUTPUT_DIR/unusual_pod5/new_attrib_in_tracking.slow5
# blue-crab p2s $POD5_DIR/unusual_pod5/new_attrib_in_tracking.pod5 -o $OUTPUT_FILE 2> $LOG || die "testcase $TESTCASE_NO failed"
# grep -q -i "WARNING.*converting.*to string" $LOG || die "Warning in testcase $TESTCASE_NO failed"
# diff $EXP_SLOW5_DIR/unusual_pod5/new_attrib_in_tracking.slow5 $OUTPUT_FILE  > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.10
# echo "------------------- p2s testcase $TESTCASE_NO >>> new string attribute in context tags  -------------------"
# blue-crab p2s $POD5_DIR/unusual_pod5/new_str_attrib_in_context.pod5 -o $OUTPUT_DIR/unusual_pod5/new_str_attrib_in_context.slow5
# diff $EXP_SLOW5_DIR/unusual_pod5/new_str_attrib_in_context.slow5 $OUTPUT_DIR/unusual_pod5/new_str_attrib_in_context.slow5  > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.11
# echo "------------------- p2s testcase $TESTCASE_NO >>> new string attribute in tracking id  -------------------"
# blue-crab p2s $POD5_DIR/unusual_pod5/new_str_attrib_in_tracking.pod5 -o $OUTPUT_DIR/unusual_pod5/new_str_attrib_in_tracking.slow5
# diff $EXP_SLOW5_DIR/unusual_pod5/new_str_attrib_in_tracking.slow5 $OUTPUT_DIR/unusual_pod5/new_str_attrib_in_tracking.slow5  > /dev/null || die "ERROR: diff failed p2s_test testcase $TESTCASE_NO"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.12
# echo "------------------- p2s testcase $TESTCASE_NO >>> new attribute in raw  -------------------"
# #This is likely to be a per-read attribute that we need to inspect manually. So must Error out unless -a is specified.
# blue-crab p2s $POD5_DIR/unusual_pod5/new_attrib_in_raw.pod5 -o $OUTPUT_DIR/err.slow5  2> $OUTPUT_DIR/err.log  && die "testcase $TESTCASE_NO failed"
# cat $OUTPUT_DIR/err.log
# grep -q "ERROR.*Attribute .* in .* is unexpected" $OUTPUT_DIR/err.log || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.13
# echo "------------------- p2s testcase $TESTCASE_NO >>> new attribute in read -------------------"
# # #This is likely to be a per-read attribute that we need to inspect manually. So must Error out unless -a is specified.
# blue-crab p2s $POD5_DIR/unusual_pod5/new_attrib_in_read.pod5 -o $OUTPUT_DIR/err.slow5 2> $OUTPUT_DIR/err.log && die "testcase $TESTCASE_NO failed"
# grep -q "ERROR.*unexpected" $OUTPUT_DIR/err.log || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.14
# echo "------------------- p2s testcase $TESTCASE_NO >>> new attribute in channel -------------------"
# # #This is likely to be a per-read attribute that we need to inspect manually. So must Error out unless -a is specified.
# blue-crab p2s $POD5_DIR/unusual_pod5/new_attrib_in_channel.pod5 -o $OUTPUT_DIR/err.slow5 2> $OUTPUT_DIR/err.log && die "testcase $TESTCASE_NO failed"
# grep -q "ERROR.*Attribute .* in .* is unexpected" $OUTPUT_DIR/err.log || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


# TESTCASE_NO=6.15
# echo "------------------- p2s testcase $TESTCASE_NO >>> new group   -------------------"
# # Unless the group is /Analyses which we ignore anyway, we will need to manually inspect what the newly added group is
# blue-crab p2s $POD5_DIR/unusual_pod5/new_group.pod5 -o $OUTPUT_DIR/err.slow5  2> $OUTPUT_DIR/err.log && die "testcase $TESTCASE_NO failed"
# grep -q "ERROR.*Attribute .* in .* is unexpected" $OUTPUT_DIR/err.log || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=6.16
# echo "------------------- p2s testcase $TESTCASE_NO >>> pore type set   -------------------"
# # if pore type is something othe rthan being empty or "no_set", we need to manually investigate what the heck thi sis
# blue-crab p2s $POD5_DIR/unusual_pod5/pore_set.pod5 -o $OUTPUT_DIR/err.slow5 2> $OUTPUT_DIR/err.log  && die "testcase $TESTCASE_NO failed"
# grep -q "ERROR.*expected to be 'not_set'" $OUTPUT_DIR/err.log || die "Error in testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4



# ####################### Erroeneous POD5 ########################

TESTCASE_NO=7.1
echo "------------------- p2s testcase $TESTCASE_NO >>> not a pod5 -------------------"
blue-crab p2s $POD5_DIR/err_pod5/not_a_pod5.pod5 -o $OUTPUT_DIR/err.slow5 &&  die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=7.2
echo "------------------- p2s testcase $TESTCASE_NO >>> non existent file -------------------"
blue-crab p2s $POD5_DIR/err_pod5/there_is_no_such_pod5.pod5 -o $OUTPUT_DIR/err.slow5 &&  die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=7.3
echo "------------------- p2s testcase $TESTCASE_NO >>> empty directory -------------------"
blue-crab p2s $POD5_DIR/err_pod5/empty_dir -o $OUTPUT_DIR/err.slow5 &&  die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=7.4
echo "------------------- p2s testcase $TESTCASE_NO >>> empty pod5 file -------------------"
blue-crab p2s $POD5_DIR/err_pod5/empty_pod5.pod5 -o $OUTPUT_DIR/err.slow5 &&  die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.5
# echo "------------------- p2s testcase $TESTCASE_NO >>> # in read id at the beginning -------------------"
# blue-crab p2s $POD5_DIR/err_pod5/malformed_readid1.pod5 -o $OUTPUT_DIR/err.slow5 && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.6
# echo "------------------- p2s testcase $TESTCASE_NO >>> @ in read id at the beginning -------------------"
# blue-crab p2s $POD5_DIR/err_pod5/malformed_readid1.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.7
# echo "------------------- p2s testcase $TESTCASE_NO >>> Duplicated attribute -------------------"
# If there is a duplicate header attribute coming from two separate groups, need some manual investigation
# blue-crab p2s $POD5_DIR/err_pod5/dupli_attrib.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.8
# echo "------------------- p2s testcase $TESTCASE_NO >>> tab in attribute name 'operating system'-------------------"
# blue-crab p2s $POD5_DIR/err_pod5/tab_in_attrib.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.9
# echo "------------------- p2s testcase $TESTCASE_NO >>> new line in attribute 'exp_script_name' value-------------------"
# blue-crab p2s $POD5_DIR/err_pod5/newline_in_attrib.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.10
# echo "------------------- p2s testcase $TESTCASE_NO >>> new line in field name 'channel number'-------------------"
# blue-crab p2s $POD5_DIR/err_pod5/newline_in_field.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.11
# echo "------------------- p2s testcase $TESTCASE_NO >>> tab in field value 'channel number'-------------------"
# blue-crab p2s $POD5_DIR/err_pod5/tab_in_field.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.12
# echo "------------------- p2s testcase $TESTCASE_NO >>> primary field 'range' missing -------------------"
# blue-crab p2s $POD5_DIR/err_pod5/missing_primary_field.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.13
# echo "------------------- p2s testcase $TESTCASE_NO >>> primary field 'range' wrong type -------------------"
# any primary field should match to what we expect
# blue-crab p2s $POD5_DIR/err_pod5/primary_field_wrong_type.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.14
# any auxilliary field should match to what we expect (note: multiple datatypes can be expected, if we know about this)
# echo "------------------- p2s testcase $TESTCASE_NO >>> aux field 'channel number' wrong type -------------------"
# blue-crab p2s $POD5_DIR/err_pod5/aux_field_wrong_type.pod5 -o $OUTPUT_DIR/err.slow5  && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

# TESTCASE_NO=7.15
# echo "------------------- p2s testcase $TESTCASE_NO >>> R7 file   -------------------"
# blue-crab p2s $POD5_DIR/err_pod5/R7_1.pod5 -o $OUTPUT_DIR/err.slow5 && die "testcase $TESTCASE_NO failed"
# echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4

TESTCASE_NO=7.16
echo "------------------- p2s testcase $TESTCASE_NO >>> all pod5 files were skipped   -------------------"
blue-crab p2s $POD5_DIR/err_pod5/ -o $OUTPUT_DIR/err.slow5 -p1 && die "testcase $TESTCASE_NO failed"
echo -e "${GREEN}testcase $TESTCASE_NO passed${NC}" 1>&3 2>&4


rm -r $OUTPUT_DIR || die "Removing $OUTPUT_DIR failed"

exit 0
