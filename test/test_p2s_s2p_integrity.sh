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

# Run p2s, s2p, and again p2s and check if first produced slow5s are same as the last set.
Usage1="p2s_s2p_integrity_test.sh"
Usage2="p2s_s2p_integrity_test.sh [path to pod5 directory] [path to create a temporary directory] [clean_fscache -f (optional)]"

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

pod5_DIR="$REL_PATH/data/raw/p2s/pod5/"
TEMP_DIR="$REL_PATH/data/out/p2s_s2p_integrity/"
if [[ "$#" -ge 2 ]]; then
  pod5_DIR=$1
  TEMP_DIR="$2/p2s_s2p_integrity_test"
fi

p2s_atm1_OUTPUT="$TEMP_DIR/p2s_attempt1"
p2s_atm1_OUTPUT_ASCII="$TEMP_DIR/p2s_attempt1_ascii.slow5"
s2p_OUTPUT="$TEMP_DIR/s2p"
p2s_atm2_OUTPUT="$TEMP_DIR/p2s_attempt2"
p2s_atm2_OUTPUT_ASCII="$TEMP_DIR/p2s_attempt2_ascii.slow5"
SLOW5TOOLS="$TEMP_DIR/slow5tools/slow5tools"

test -d "$TEMP_DIR" && rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR" || die "Creating $TEMP_DIRq failed"
mkdir "$p2s_atm1_OUTPUT" || die "Creating $p2s_atm1_OUTPUT failed"
mkdir "$s2p_OUTPUT" || die "Creating $s2p_OUTPUT failed"
mkdir "$p2s_atm2_OUTPUT" || die "Creating $p2s_atm2_OUTPUT failed"

CURRENT=$(pwd)
cd $TEMP_DIR || die "cd $TEMP_DIR failed"
wget "https://github.com/hasindu2008/slow5tools/releases/download/v1.0.0/slow5tools-v1.0.0-release.tar.gz" || die "wget failed"
tar -xzf slow5tools-v1.0.0-release.tar.gz || die "tar failed"
mv slow5tools-v1.0.0 slow5tools || die "mv failed"
cd slow5tools || die "cd slow5tools failed"
make disable_hdf5=1 -j 4 || die "make failed"
cd $CURRENT || die "cd $CURRENT failed"

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

$SLOW5TOOLS merge ${p2s_atm1_OUTPUT} -o ${p2s_atm1_OUTPUT_ASCII} || die "slow5tools merge failed"
$SLOW5TOOLS merge ${p2s_atm2_OUTPUT} -o ${p2s_atm2_OUTPUT_ASCII} || die "slow5tools merge failed"

echo "p2s might not create the same exact header lines (starting with '@') from after s2p pod5s"
echo "Running diff only on lines starting with '@'. If there are no differences the following line is blank"
diff --ignore-matching-lines=?@ "$p2s_atm1_OUTPUT_ASCII" "$p2s_atm2_OUTPUT_ASCII"
echo
echo "Again running diff (ignoring header lines starting with '@'"
diff --ignore-matching-lines=@ "$p2s_atm1_OUTPUT_ASCII" "$p2s_atm2_OUTPUT_ASCII" > /dev/null
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