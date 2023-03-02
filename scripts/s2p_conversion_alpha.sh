#!/bin/bash

# This script will convert slow5 to pod5.
# Since pod5 writing API is not yet stable this conversion utilizes slow5tool's s2f.
#
# usage: ./s2p_conversion_alpha.sh input.slow5 output.pod5

RED='\033[0;31m' ; GREEN='\033[0;32m' ; NC='\033[0m' # No Color
die() { echo -e "${RED}$1${NC}" >&2 ; echo ; exit 1 ; } # terminate script
info() {  echo ; echo -e "${GREEN}$1${NC}" >&2 ; }

Usage="./s2p_conversion_alpha.sh input.slow5 output.pod5"
NUMBER_ARGS=2
if [[ "$#" -lt ${NUMBER_ARGS} ]]; then
	info "Usage: ${Usage}"
	exit 1
fi
input_slow5=${1}
output_pod5=${2}

slow5tools s2f ${input_slow5} -o temp.fast5 || die "slow5tools failed"
pod5 convert fast5 temp.fast5 ${output_pod5} || die "pod5 conversion failed"
rm temp.fast5

info "success"
exit()
