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

###############################################################################

Usage="test_extensive.sh"

set -e
set -x

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

# terminate script
die() {
    echo -e "${RED}$1${NC}" >&2
    echo
    exit 1
}

TMP_DIR=/data/slow5-testdata/tmp/
test -d $TMP_DIR && rm -r $TMP_DIR
rm -f *.log
guppy_basecaller --version > /dev/null || die "guppy_basecaller not in path"
scripts/blue-crab --version > /dev/null || die "bluecrab not in path"
slow5tools --version > /dev/null || die "slow5tools not in path"

echo "********************************HG2_subsubsample****************************************"
DATA_HG2=/data/slow5-testdata/hg2_prom_lsk114_5khz_subsubsample
test -d $DATA_HG2 || die "ERROR: $DATA_HG2 not found. Download from https://slow5.bioinf.science/hg2_prom_5khz_subsubsample and extract, split the blow5 and convert them and put then under pod5/"
mkdir $TMP_DIR || die "Creating $TMP_DIR failed"
test/test_with_guppy.sh $DATA_HG2/pod5 $TMP_DIR slow5tools /install/ont-guppy-6.5.7/bin/guppy_basecaller blue-crab &> test_s2p_with_guppy_sub.log || die "test_s2p_with_guppy failed"
rm -r $TMP_DIR
echo "Guppy test passed yey!"
mkdir $TMP_DIR || die "Creating $TMP_DIR failed"
test/test_p2s_s2p_integrity.sh $DATA_HG2/pod5 $TMP_DIR &> p2s_s2p_integrity_test.txt || die "p2s_s2p_integrity_test failed"
rm -r $TMP_DIR
echo "test_p2s_s2p_integrity passed!"
echo ""

echo "all done!"
exit 0
