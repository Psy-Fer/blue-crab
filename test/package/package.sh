#!/bin/bash

die (){
    echo >&2 "$@"
    exit 1
}

# blue-crab needs python>=3.10, and pyslow5 only ships wheels up to cp311,
# so 3.11 both satisfies the package and avoids building htslib from source
PYTHON_PATCH="3.11.13"
PBS_RELEASE="20250712"
PYTHON_VERSION="python${PYTHON_PATCH%.*}"
PBS_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PBS_RELEASE}"
PY_VENV="blue-crab-venv"
ARCH=$(uname -m)
OS=$(uname -s)
REPO_LINK="https://github.com/Psy-Fer/blue-crab.git"
BRANCH="${2:-main}"
TOOL="blue-crab"
MOD="blue_crab"
# set REPO_DIR to an existing checkout to skip the clone, the workflow mounts one in
REPO_DIR="${REPO_DIR:-}"

echo "O/S:${OS} architecture:${ARCH} python:${PYTHON_VERSION}"

if [ "${OS}" == "Linux"  ] && [ "${ARCH}" == "x86_64" ];
then
    # pyarrow (via pod5) only ships manylinux_2_28 wheels on python>=3.10,
    # so this has to be built on a glibc>=2.28 image, see package_pypi.yml
    if command -v dnf > /dev/null 2>&1; then
        dnf install -y wget gcc make zlib-devel git || die "system tools install failed"
    else
        apt-get update || die "apt-get update failed"
        apt install wget gcc make zlib1g-dev git -y || die "system tools install failed"
    fi
    PY_TARBALL="cpython-${PYTHON_PATCH}+${PBS_RELEASE}-x86_64-unknown-linux-gnu-install_only.tar.gz"
elif [[ "${OS}" == "Darwin" && ( "${ARCH}" == "arm64" || "${ARCH}" == "aarch64" ) ]];
then
    PY_TARBALL="cpython-${PYTHON_PATCH}+${PBS_RELEASE}-aarch64-apple-darwin-install_only.tar.gz"
elif [ "${OS}" == "Darwin"  ] && [ "${ARCH}" == "x86_64" ];
then
    PY_TARBALL="cpython-${PYTHON_PATCH}+${PBS_RELEASE}-x86_64-apple-darwin-install_only.tar.gz"
else
    die "Unsupported O/S ${OS} or architecture ${ARCH} for packaging."
fi

wget ${PBS_URL}/${PY_TARBALL} || die "python wget failed"
tar xf ${PY_TARBALL} || die "untar python failed"

python/bin/${PYTHON_VERSION} -m venv ${PY_VENV} || die "create venv failed"
source ${PY_VENV}/bin/activate || die "sourcing venv failed"
pip install --upgrade pip || die "upgrade pip failed"
export CC=gcc
export HTSLIB_CONFIGURE_OPTIONS="--enable-bz2=no --enable-lzma=no --with-libdeflate=no --enable-libcurl=no  --enable-gcs=no --enable-s3=no"

if [[ "$1" == "test_pypi" ]]; then
    echo "Installing from Test PyPI"
    pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple ${TOOL} --pre || die "test.pip install ${TOOL} failed"
else
    echo "Installing from PyPI"
    pip install ${TOOL} --no-cache || die "pip install ${TOOL} failed"
fi

# name the tarball after what pip actually installed, not the newest git tag,
# as pip quietly falls back to an older release when the current one is not installable
VERSION=$(pip show ${TOOL} | awk '/^Version:/ {print $2}')
test -z "${VERSION}" && die "could not determine installed ${TOOL} version"
echo "installed ${TOOL} version: ${VERSION}"

find ./ -name __pycache__ -type d -prune -exec rm -rf {} + || die "removing pycache failed"
mv ${PY_VENV}/bin/${TOOL} python/bin/ || die "moving ${TOOL} to bin failed"
cp -r ${PY_VENV}/lib/${PYTHON_VERSION}/site-packages/* python/lib/${PYTHON_VERSION}/site-packages/ || die "copying site-packages failed"

if [ "${OS}" == "Linux"  ]; then
    sed -i "1s|.*|#!/usr/bin/env ${PYTHON_VERSION}|" python/bin/${TOOL}  || die "changing headerline failed"
elif [ "${OS}" == "Darwin"  ]; then
    sed -i '' "1s/.*/#\!\/usr\/bin\/env ${PYTHON_VERSION}/" python/bin/${TOOL} || die "changing headerline failed"
fi

if [ -n "${REPO_DIR}" ] && [ -d "${REPO_DIR}/docs" ]; then
    echo "using local source: ${REPO_DIR}"
    SRC_DIR="${REPO_DIR}"
else
    git clone --depth 1 --branch "${BRANCH}" ${REPO_LINK} || die "Failed to clone ${TOOL} branch ${BRANCH}"
    SRC_DIR="${TOOL}"
fi

# catch a silent pip fallback before it gets tarred up and released
SRC_VERSION=$(sed -n 's/^__version__[[:space:]]*=[[:space:]]*"\(.*\)"/\1/p' ${SRC_DIR}/src/${MOD}/_version.py)
test -z "${SRC_VERSION}" && die "could not read version from ${SRC_DIR}/src/${MOD}/_version.py"
if [ "${SRC_VERSION}" != "${VERSION}" ]; then
    if [[ "$1" == "test_pypi" ]]; then
        echo >&2 "warning: source is ${SRC_VERSION} but pip installed ${VERSION}"
    else
        die "version mismatch: source is ${SRC_VERSION} but pip installed ${VERSION} - is ${TOOL} ${SRC_VERSION} published and installable on ${PYTHON_VERSION}?"
    fi
fi

cp -r ${SRC_DIR}/docs python || die "docs copy failed"
cp ${SRC_DIR}/test/package/${TOOL} python || die "script copy failed"
cp ${SRC_DIR}/LICENSE python || die "license copy failed"
cp ${SRC_DIR}/README.md python || die "readme copy failed"

if [ "${SRC_DIR}" == "${TOOL}" ]; then
    rm -rf ${TOOL} || die "remove cloned dir failed"
fi

OS_NAME="linux"
if [ "${OS}" == "Darwin"  ]; then
    OS_NAME="macos"
fi
ARCH_NAME="x86_64"
if [ "${ARCH}" == "arm64"  ] || [ "${ARCH}" == "aarch64" ]; then
    ARCH_NAME="arm64"
fi
TOOL_NAME=${TOOL}-v${VERSION}
TAR_NAME=${TOOL_NAME}-${ARCH_NAME}-${OS_NAME}-binaries.tar.gz
echo "TOOL_NAME: ${TOOL_NAME}"
echo "TAR_NAME: ${TAR_NAME}"

mv python/ ${TOOL_NAME} || die "renaming python to ${TOOL_NAME} failed"

tar zcvf ${TAR_NAME} ${TOOL_NAME}/ || die "tar balling ${TOOL_NAME} failed"

# if user arg "docker" is provided, copy tarball to host directory
if [[ "$1" == "docker" ]]; then
    echo "copying tar file to host directory"
    cp ${TAR_NAME} /host/ || die "copying tar file to host"
fi
