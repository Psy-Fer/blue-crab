#!/bin/bash

die (){
    echo >&2 "$@"
    exit 1
}

# wget https://github.com/indygreg/python-build-standalone/releases/download/20230726/cpython-3.8.16+20230726-aarch64-apple-darwin-install_only.tar.gz || die "python wget failed"
# tar xf cpython-3.8.16+20230726-aarch64-apple-darwin-install_only.tar.gz || die "untar python failed"

# Download Python standalone build for macOS x86_64
# wget https://github.com/indygreg/python-build-standalone/releases/download/20230726/cpython-3.8.16+20230726-x86_64-apple-darwin-install_only.tar.gz || die "python wget failed"
# tar xf cpython-3.8.16+20230726-x86_64-apple-darwin-install_only.tar.gz || die "untar python failed"

wget https://github.com/indygreg/python-build-standalone/releases/download/20250712/cpython-3.9.23+20250712-aarch64-apple-darwin-install_only.tar.gz || die "python wget failed"
tar xf cpython-3.9.23+20250712-aarch64-apple-darwin-install_only.tar.gz || die "untar python failed"

python/bin/python3.9 -m venv blue-crab-venv || die "create venv failed"
source blue-crab-venv/bin/activate || die "sourcing venc failed"
pip install --upgrade pip || die "upgrade pip failed"
export CC=gcc
export HTSLIB_CONFIGURE_OPTIONS="--enable-bz2=no --enable-lzma=no --with-libdeflate=no --enable-libcurl=no  --enable-gcs=no --enable-s3=no"
pip install blue-crab --no-cache || die "pip install blue-crab failed"


find ./ -name __pycache__ -type d | xargs rm -r || die "removing pycache failed"
mv blue-crab-venv/bin/blue-crab python/bin/ || die "moving blue-crab to bin failed"
cp -r blue-crab-venv/lib/python3.9/site-packages/* python/lib/python3.9/site-packages/ || die "copying site-packages failed"
sed -i '' "1s/.*/#\!\/usr\/bin\/env python3.9/" python/bin/blue-crab
git clone --depth 1 --branch package https://github.com/Psy-Fer/blue-crab.git  || die "Failed to clone blue-crab"

cp -r blue-crab/docs python || die "docs copy failed"
cp blue-crab/scripts/exe_file python/blue-crab || die "script copy failed" 
# cp /host/exe_file python/blue-crab || die "script copy failed" 
cp blue-crab/LICENSE python || die "license copy failed"
cp blue-crab/README.md python || die "readme copy failed"

rm -rf blue-crab || die "remove cloned dir failed"

mv python/ blue-crab || die "renaming python to blue-crab failed"

tar zcvf blue-crab.tar.gz blue-crab/ || die "tar balling blue-crab failed"
