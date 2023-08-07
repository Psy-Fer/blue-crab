
#!/bin/bash

die() {
    echo "$@" >&2
    exit 1
}

test -d ./blue-crab-venv && die "blue-crab-venv already exists"
python3 -m venv ./blue-crab-venv || die "venv failed"
source ./blue-crab-venv/bin/activate || die "venv activate failed"
python3 -m pip install --upgrade pip || die "pip upgrade failed"
python3 -m pip install setuptools wheel numpy || die "pip install setuptools wheel failed"

git clone -b pyslow5-aux-update https://github.com/hasindu2008/slow5lib || die "git clone failed"
cd slow5lib || die "cd slow5lib failed"

# do this separately, after the libs above
# for zstd build, run the following
# export PYSLOW5_ZSTD=1
python3 setup.py install || die "setup.py install failed for slow5lib"
cd ..
python3 setup.py install || die "setup.py install failed for blue-crab"

blue-crab --help || die "blue-crab --help failed"
deactivate



