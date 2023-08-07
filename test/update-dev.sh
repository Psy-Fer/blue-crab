#!/bin/bash

die() {
    echo "$@" >&2
    exit 1
}

test -d ./blue-crab-venv || die "blue-crab-venv does not exist"
source ./blue-crab-venv/bin/activate || die "venv activate failed"

cd slow5lib || die "cd slow5lib failed"
git pull || die "git pull failed"
# do this separately, after the libs above
# for zstd build, run the following
# export PYSLOW5_ZSTD=1
python3 setup.py install || die "setup.py install failed for slow5lib"
cd ..
python3 setup.py install || die "setup.py install failed for blue-crab"

blue-crab --help || die "blue-crab --help failed"
deactivate
