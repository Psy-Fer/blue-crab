# blue-crab

blue-crab is a conversion tool to convert from ONT's POD5 format to the community maintained [SLOW5/BLOW5 format](https://www.nature.com/articles/s41587-021-01147-4). Maybe one day ONT will see the light and realise column-based file formats for row-based reading is a bad idea. Till then, Crab go snap snap!
Happy converting!

SLOW5 specification: https://hasindu2008.github.io/slow5specs<br/>
slow5tools: https://github.com/hasindu2008/slow5tools<br/>
pyslow5: https://hasindu2008.github.io/slow5lib/pyslow5_api/pyslow5.html<br/>

<!---
[![BioConda Install](https://img.shields.io/conda/dn/bioconda/blue-crab.svg?style=flag&label=BioConda%20install)](https://anaconda.org/bioconda/blue-crab)
[![PyPI](https://img.shields.io/pypi/v/blue-crab.svg?style=flat)](https://pypi.python.org/pypi/blue-crab)
![PyPI - Downloads](https://img.shields.io/pypi/dm/blue-crab?label=blue-crab%20PyPi)
--->
[![Snake CI](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml/badge.svg)](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml)


# WARNING

Currently under testing. Please wait for a release. Use at your own risk.

## Setup

blue-crab requires python 3.8 or higher (limitation due to ONT's pod5 library). Using a virtual environment is recommended.

1. Install zlib development libraries (and optionally zstd development libraries).

The commands to zlib __development libraries__ on some popular distributions :
```sh
On Debian/Ubuntu : sudo apt-get install zlib1g-dev
On Fedora/CentOS : sudo dnf/yum install zlib-devel
On OS X : brew install zlib
```

SLOW5 files compressed with *zstd* offer smaller file size and better performance compared to the default *zlib*. However, *zlib* runtime library is available by default on almost all distributions unlike *zstd* and thus files compressed with *zlib* will be more 'portable'. Enabling optional *zstd* support, requires __zstd 1.3 or higher development libraries__ installed on your system:

```sh
On Debian/Ubuntu : sudo apt-get install libzstd1-dev # libzstd-dev on newer distributions if libzstd1-dev is unavailable
On Fedora/CentOS : sudo yum libzstd-devel
On OS X : brew install zstd
```

2. Create a virtual environment using Python 3.8 and install blue-crab

```
# clone the repo
git clone  https://github.com/Psy-Fer/blue-crab && cd blue-crab

# create venv
python3 -m venv ./blue-crab-venv
source ./blue-crab-venv/bin/activate
python3 -m pip install --upgrade pip

# only if you want zstd support and have installed zstd development libraries for zstd build
export PYSLOW5_ZSTD=1

# install blue-crab
python3 -m pip install .
blue-crab --help
```

You can check your Python version by invoking `python3 --version`. You can install a different version of Python as:

```
Todo: provide instructions for installing python versions using apt
```

<!---
## Other setup options

You may also use conda (todo: complete):
```
conda create -n blue-crab-env python=3.10 -y
conda activate blue-crab-env
pip install -r requirements.txt
```
--->

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

Note that default compression is *zlib* for maximise compatibility. SLOW5 files compressed with *zstd* offer smaller file size and better performance compared to the default *zlib*. If you installed blue-crab with *zstd* support, you can create zstd compressed BLOW5 as:
```
# pod5 -> zstd compressed slow5/blow5
blue-crab p2s -c zstd pod5_dir -d blow5_dir
```


# Notes

POD5 has had a number of backward compatibility-breaking changes so far. This version of blue-crab is only tested on most recent pod5 files. blue-crab simply relies on ONT's POD5 API for reading and writing POD5 files, thus, leaving the burden of managing a library that can handle all the variants of POD5 and cleaning up the mess they create. We will not invest time to handle all these various idiosyncrasies in POD5, unlike we did for hundreds of different FAST5 formats when developing slow5tools. If your POD5 files are v0.1.5 or lower, you may check [this old readme](archived/old_readme.md) out.



# Acknowledgement

[George Bouras](https://github.com/gbouras13) for providing some example becterial pod5 files. [Rasmus Kirkegaard](https://github.com/Kirk3gaard) for this [public zymo pod5 dataset](https://github.com/Kirk3gaard/2023-basecalling-benchmarks).


# Citation

> Gamaarachchi, H., Samarakoon, H., Jenner, S.P. et al. Fast nanopore sequencing data analysis with SLOW5. Nat Biotechnol 40, 1026-1029 (2022). https://doi.org/10.1038/s41587-021-01147-4

```
@article{gamaarachchi2022fast,
  title={Fast nanopore sequencing data analysis with SLOW5},
  author={Gamaarachchi, Hasindu and Samarakoon, Hiruna and Jenner, Sasha P and Ferguson, James M and Amos, Timothy G and Hammond, Jillian M and Saadat, Hassaan and Smith, Martin A and Parameswaran, Sri and Deveson, Ira W},
  journal={Nature biotechnology},
  pages={1--4},
  year={2022},
  publisher={Nature Publishing Group}
}
```