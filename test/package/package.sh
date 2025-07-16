#!/bin/bash

die (){
    echo >&2 "$@"
    exit 1
}

PYTHON_VERSION="python3.9"
ARCH=$(uname -m)
OS=$(uname -s)

if [ "${OS}" == "Linux"  ] && [ "${ARCH}" == "x86_64" ];
then
    apt-get update || die "apt-get update failed"
    apt install wget gcc make zlib1g-dev git -y || die "system tools install failed"
    wget https://github.com/indygreg/python-build-standalone/releases/download/20250712/cpython-3.9.23+20250712-x86_64-unknown-linux-gnu-install_only.tar.gz || die "python wget failed"
    tar xf cpython-3.9.23+20250712-x86_64-unknown-linux-gnu-install_only.tar.gz || die "untar python failed"
elif [[ "${OS}" == "Darwin" && ( "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ) ]];
then
    wget https://github.com/indygreg/python-build-standalone/releases/download/20250712/cpython-3.9.23+20250712-aarch64-apple-darwin-install_only.tar.gz || die "python wget failed"
    tar xf cpython-3.9.23+20250712-aarch64-apple-darwin-install_only.tar.gz || die "untar python failed"
elif [ "${OS}" == "Darwin"  ] && [ "${ARCH}" == "x86_64" ];
then
    wget https://github.com/indygreg/python-build-standalone/releases/download/20250712/cpython-3.9.23+20250712-x86_64-apple-darwin-install_only.tar.gz || die "python wget failed"
    tar xf cpython-3.9.23+20250712-x86_64-apple-darwin-install_only.tar.gz || die "untar python failed"
else
    die "Unsupported O/S ${OS} or architecture ${ARCH} for packaging."
fi

python/bin/${PYTHON_VERSION} -m venv blue-crab-venv || die "create venv failed"
source blue-crab-venv/bin/activate || die "sourcing venc failed"
pip install --upgrade pip || die "upgrade pip failed"
export CC=gcc
export HTSLIB_CONFIGURE_OPTIONS="--enable-bz2=no --enable-lzma=no --with-libdeflate=no --enable-libcurl=no  --enable-gcs=no --enable-s3=no"
pip install blue-crab --no-cache || die "pip install blue-crab failed"

find ./ -name __pycache__ -type d | xargs rm -r || die "removing pycache failed"
mv blue-crab-venv/bin/blue-crab python/bin/ || die "moving blue-crab to bin failed"
cp -r blue-crab-venv/lib/${PYTHON_VERSION}/site-packages/* python/lib/${PYTHON_VERSION}/site-packages/ || die "copying site-packages failed"

if [ "${OS}" == "Linux"  ]; then
    sed -i "s/blue-crab-venv\/bin\/${PYTHON_VERSION}/\/usr\/bin\/env ${PYTHON_VERSION}/g" python/bin/blue-crab  || die "changing headerline failed"
elif [ "${OS}" == "Darwin"  ]; then
    sed -i '' "1s/.*/#\!\/usr\/bin\/env ${PYTHON_VERSION}/" python/bin/blue-crab || die "changing headerline failed"
fi

git clone --depth 1 --branch package https://github.com/Psy-Fer/blue-crab.git  || die "Failed to clone blue-crab"
cp -r blue-crab/docs python || die "docs copy failed"
cp blue-crab/test/package/exe_file python/blue-crab || die "script copy failed" 
cp blue-crab/LICENSE python || die "license copy failed"
cp blue-crab/README.md python || die "readme copy failed"

rm -rf blue-crab || die "remove cloned dir failed"

mv python/ blue-crab || die "renaming python to blue-crab failed"

tar zcvf blue-crab.tar.gz blue-crab/ || die "tar balling blue-crab failed"

# if user arg "docker" is provided, copy tarball to host directory
if [[ "$1" == "docker" ]]; then
    echo "copying tar file to host directory"
    cp blue-crab.tar.gz /host/ || die "copying tar file to host"
fi
