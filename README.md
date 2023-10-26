# blue-crab

blue-crab is a conversion tool to convert from ONT's POD5 format to the community maintained [SLOW5/BLOW5 format](https://www.nature.com/articles/s41587-021-01147-4). Maybe one day ONT will see the light and realise column-based file formats for row-based reading is a bad idea. Till then, Crab go snap snap!
Happy converting!

SLOW5 specification: https://hasindu2008.github.io/slow5specs<br/>
slow5tools: https://github.com/hasindu2008/slow5tools<br/>
pyslow5: https://hasindu2008.github.io/slow5lib/pyslow5_api/pyslow5.html<br/>

<!---
[![BioConda Install](https://img.shields.io/conda/dn/bioconda/blue-crab.svg?style=flag&label=BioConda%20install)](https://anaconda.org/bioconda/blue-crab)
![PyPI - Downloads](https://img.shields.io/pypi/dm/blue-crab)
--->
![PyPI Downloads](https://img.shields.io/pypi/dm/blue-crab?label=pypi%20downloads)
[![PyPI](https://img.shields.io/pypi/v/blue-crab.svg?style=flat)](https://pypi.python.org/pypi/blue-crab)
[![Snake CI](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml/badge.svg)](https://github.com/Psy-Fer/blue-crab/actions/workflows/snake.yml)


# WARNING

While we test as much as we can and do our very best to ensure 100% data parity, we have no control over what ONT will do to pod5.

Given their history of ad-hoc changes, there is bound to be cases in the future where this breaks the conversion.

You may use commands like [slow5tools](https://hasindu2008.github.io/slow5tools/) quickcheck and index to verify the integrity of the created S/BLOW5 files.


## Quickstart

```
python3 -m venv ./blue-crab-venv
source ./blue-crab-venv/bin/activate
python3 -m pip install --upgrade pip

pip install blue-crab

blue-crab --help
```


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

### pick option 2 or 3

2. Create a virtual environment using Python 3.8+ and install blue-crab from pip

    ```
    python3 -m venv ./blue-crab-venv
    source ./blue-crab-venv/bin/activate
    python3 -m pip install --upgrade pip

    # only if you want zstd support and have installed zstd development libraries for zstd build
    export PYSLOW5_ZSTD=1

    pip install blue-crab

    blue-crab --help
    ```

3. Create a virtual environment using Python 3.8+ and install blue-crab from source

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

    You can check your Python version by invoking `python3 --version`. If your native python3 meets this requirement of >=3.8, you can use that, or use a
specific version installed with deadsnakes below. If you install with deadsnakes, you will need to call that specific python, such as python3.8 or python3.9, in all the following commands until you create a virtual environment with venv. Then once activated, you can just use python3. To install a specific version of python, the deadsnakes ppa is a good place to start:

    ```
    # This is an example for installing python3.8
    # you can then call that specific python version
    # > python3.8 -m pip --version
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt install python3.8 python3.8-dev python3.8-venv
    ```


### Optional: wrapper script and adding to PATH

Suppose the name of the virtual environment you created is blue-crab-venv and resides directly in the root of the cloned blue-crab git repository. In that case, you can use the wrapper script available under /path/to/repository/scripts/blue-crab for conveniently executing blue-crab. This script will automatically source the virtual environment, execute the blue-crab with the parameters you specified and finally deactivate the virtual environment. If you add the path of /path/to/repository/scripts/ to your PATH environment variable, you can simply use blue-crab from anywhere.

### Optional: real-time POD5 to BLOW5 conversion

A script for performing real-time POD5 to BLOW5 conversion during sequencing is provided [here](scripts/realtime-p2s/) along with instructions.

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


# Example comparison

The following table compares an original 5khz pod5 file from the public zymo dataset (link below), containing 10k reads. Pod5 is using its default VBZ compression which is a mix of zstd and svb-zd for the signal.

The blow5 files are conversions made using blue-crab and timed with `/usr/bin/time -v <cmd>`. They were carried out on an XPS 15 laptop with a modern SSD hard drive. They all have signal compression set to use svb-zd. Using `python3.11.3`.

The table shows `pod5-vbz` is slightly smaller than both `blow5-zstd` and `blow5-zlib`. We prefer to default to `blow5-zlib` as it is more portable as zlib comes with most systems (as discussed above). If you want the best compression and faster conversion times however, `blow5-zstd` is the clear winner for blow5.

| method     | size (mb) | time (s)|
| :---:      | :---:     | :---:   |
| pod5-vbz   | **679**   | -       |
| blow5-zstd | 681       | **3.91**|
| blow5-zlib | 689       | 7.86    |
| -          | -         | -       |
| blow5-xxx  | 666       | -       |

I have included an example `blow5-xxx` to show that we can make the files even smaller than pod5, and this work is under active development. However those compression techniques are currently not available in blue-crab.


# Acknowledgement

[George Bouras](https://github.com/gbouras13) for providing some example becterial pod5 files. [Rasmus Kirkegaard](https://github.com/Kirk3gaard) for this [public zymo pod5 dataset](https://github.com/Kirk3gaard/2023-basecalling-benchmarks). [George](https://github.com/jorj1988) from ONT for help in understanding pod5 stuff.


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
