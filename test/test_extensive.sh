#!/bin/bash

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

echo "********************************zymo****************************************"
DATA_ZYMO=/data/jamfer/zymo/
test -d $DATA_ZYMO || die "ERROR: $DATA_ZYMO not found. Download from https://slow5.page.link/na12878_prom_sub and extract"
mkdir $TMP_DIR || die "Creating $TMP_DIR failed"
test/test_with_guppy.sh $DATA_ZYMO/fast5 $TMP_DIR ./slow5tools guppy_basecaller &> test_s2f_with_guppy_sub.log || die "test_s2f_with_guppy failed"
rm -r $TMP_DIR
echo "Guppy test passed yey!"
mkdir $TMP_DIR || die "Creating $TMP_DIR failed"
test/test_f2s_s2f_integrity.sh $DATA_ZYMO/fast5 $TMP_DIR &> f2s_s2f_integrity_test.txt || die "f2s_s2f_integrity_test failed"
rm -r $TMP_DIR
echo "test_f2s_s2f_integrity passed!"
echo ""

echo "all done!"
exit 0
