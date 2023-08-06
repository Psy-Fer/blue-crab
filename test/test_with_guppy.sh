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

# first do p2s, s2p and then basecall

Usage="test_s2p_with_guppy.sh [path to pod5 directory] [path to create a temporary directory] [path to slow5tools executable] [path to guppy executable] [path to bluecrab]"

if [[ "$#" -lt 4 ]]; then
	echo "Usage: $Usage"
	exit 1
fi

RED='\033[0;31m' ; GREEN='\033[0;32m' ; NC='\033[0m' # No Color
die() { echo -e "${RED}$1${NC}" >&2 ; echo ; exit 1 ; } # terminate script
#ask before deleting. if yes then delete. if no then exit.
# to automatically answer:$ yes | script or use yes n | script
ask() { echo -n "Directory $1 exists. Delete and create again? (y/n)? " ; read answer ; if [ "$answer" != "${answer#[Nn]}" ] ;then exit ; fi ; echo ; }

set -e
set -x

POD5_DIR=$1
OUTPUT_DIR=$2/test_with_guppy_test
SLOW5TOOLS=$3
GUPPY_BASECALLER=$4
BLUECRAB=$5

P2S_OUTPUT_DIR=$OUTPUT_DIR/p2s
S2P_OUTPUT_DIR=$OUTPUT_DIR/s2p
GUPPY_OUTPUT_ORIGINAL=$OUTPUT_DIR/guppy_output_original
GUPPY_OUTPUT_S2P=$OUTPUT_DIR/guppy_output_s2p

# create test directory
test -d "$OUTPUT_DIR" && ask "$OUTPUT_DIR"
test -d  $OUTPUT_DIR && rm -r $OUTPUT_DIR
mkdir $OUTPUT_DIR || die "mkdir $OUTPUT_DIR failed"

IOP=40

$BLUECRAB p2s  $POD5_DIR -d $P2S_OUTPUT_DIR --iop $IOP || die "slow5tools p2s failed"
$SLOW5TOOLS merge $P2S_OUTPUT_DIR -o $OUTPUT_DIR/merged.blow5 -t $IOP || die "slow5tools merge failed"
$SLOW5TOOLS split $OUTPUT_DIR/merged.blow5  -d $OUTPUT_DIR/split -r 4000 || die "slow5tools split failed"
CONFIG=dna_r10.4.1_e8.2_400bps_5khz_fast.cfg

$BLUECRAB s2p $OUTPUT_DIR/split -d $S2P_OUTPUT_DIR --iop $IOP || die "slow5tools s2p failed"

$GUPPY_BASECALLER -c ${CONFIG} -i $POD5_DIR -s $GUPPY_OUTPUT_ORIGINAL -r --device cuda:all || die "Guppy failed"
$GUPPY_BASECALLER -c ${CONFIG}  -i $S2P_OUTPUT_DIR -s $GUPPY_OUTPUT_S2P -r --device cuda:all || die "Guppy failed"

find $GUPPY_OUTPUT_S2P/ -name '*.fastq' -exec cat {} + | paste - - - -  | sort -k1,1  | tr '\t' '\n' > $OUTPUT_DIR/guppy_output_s2p_sorted.fastq  || die "GUPPY_OUTPUT_s2p/*.fastq cat failed"
find $GUPPY_OUTPUT_ORIGINAL/ -name '*.fastq' -exec cat {} + | paste - - - - | sort -k1,1  | tr '\t' '\n' > $OUTPUT_DIR/guppy_output_original_sorted.fastq || die "GUPPY_OUTPUT_ORIGINAL/*.fastq cat failed"

echo "diff sorted fastq files"
diff -q $OUTPUT_DIR/guppy_output_s2p_sorted.fastq $OUTPUT_DIR/guppy_output_original_sorted.fastq  || die "ERROR: diff failed for guppy_output_s2p_sorted.fastq guppy_output_original_sorted.fastq files"
echo -e "${GREEN}diff of fastq passed${NC}"

cut -f2,3,5- $GUPPY_OUTPUT_ORIGINAL/sequencing_summary.txt | sort -k1 > $GUPPY_OUTPUT_ORIGINAL/sorted_sequencing_summary.txt
cut -f2,3,5- $GUPPY_OUTPUT_S2P/sequencing_summary.txt | sort -k1 > $GUPPY_OUTPUT_S2P/sorted_sequencing_summary.txt
diff -q $GUPPY_OUTPUT_ORIGINAL/sorted_sequencing_summary.txt $GUPPY_OUTPUT_S2P/sorted_sequencing_summary.txt > /dev/null || die "diff sorted sequencing summary files failed"
echo -e "${GREEN}diff of sequencing summary files passed${NC}"

rm -r "$OUTPUT_DIR" || die "could not delete $OUTPUT_DIR"

exit
