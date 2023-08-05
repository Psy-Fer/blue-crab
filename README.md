# blue-crab

blue-crab is a conversion tool to convert from ONT's POD5 format to the community maintained [SLOW5/BLOW5 format](https://www.nature.com/articles/s41587-021-01147-4). Maybe one day ONT will see the light and realise column-based file formats for row-based reading is a bad idea. Till then, Crab go snap snap!
Happy converting!

SLOW5 specification: https://hasindu2008.github.io/slow5specs<br/>

<!---
[![BioConda Install](https://img.shields.io/conda/dn/bioconda/blue-crab.svg?style=flag&label=BioConda%20install)](https://anaconda.org/bioconda/blue-crab)
[![PyPI](https://img.shields.io/pypi/v/blue-crab.svg?style=flat)](https://pypi.python.org/pypi/blue-crab)
![PyPI - Downloads](https://img.shields.io/pypi/dm/blue-crab?label=blue-crab%20PyPi)
--->
[![Snake CI](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml/badge.svg)](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml)


# WARNING

Currently under testing. Please wait for a release. Use at your own risk.

## Setup

blue-crab requires python 3.8 or higher (limitation due to ONT's pod5 library). Using a virtual environment is recommended:

```
python3 -m venv ./blue-crab-venv
source ./blue-crab-venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install setuptools wheel
# do this separately, after the libs above
# for zstd build, run the following
export PYSLOW5_ZSTD=1
python3 setup.py install

blue-crab --help
```

## Other setup options

Todo: provide instructions for instalating python versions and also installing zlib/zstd development libraries.

You may also use conda (todo: complete):
```
conda create -n blue-crab-env python=3.10 -y
conda activate blue-crab-env
pip install -r requirements.txt
```

## Usage

Please visit the [manual page](docs/cli.md) for all the commands and options. Some examples are give below:

```
# pod5 file -> slow5/blow5 file
blue-crab p2s example.pod5 -o example.blow5

# pod5 directory -> slow5/blow5 directory
blue-crab p2s pod5_dir -d blow5_dir

# slow5/blow5 -> pod5
blue-crab s2p example.blow5 -o example.pod5
```


# Notes

POD5 has had a number of backward compatibility breaking changes so far. This version of blue-crab is only tested on most recent pod5 files. blue-crab simply relies on ONT's POD5 API for reading and writing POD5 files, thus, leaving the burden of managing a library that can handle all the variants of POD5 and cleaning up the mess they create. We will not invest time to handle all these various idiosyncrasies in POD5, unlike we did for hundreds of different FAST5 formats when developing slow5tools. If your POD5 files are v0.1.5 or lower, you may check [this old readme](archived/old_readme.md) out.



# Acknowledgement

[George Bouras](https://github.com/gbouras13) for providing some example becterial pod5 files. [Rasmus Kirkegaard](https://github.com/Kirk3gaard) for this [public zymo pod5 dataset](https://github.com/Kirk3gaard/2023-basecalling-benchmarks).