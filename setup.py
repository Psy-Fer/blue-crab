import setuptools
from os import path

PKG_NAME = "blue-crab"
MOD_NAME = "src"

# add readme to long description as that's what pypi sees
with open("README.md", "r") as f:
    long_description = f.read()


# get version from file rather than here so change isn't in this file
__version__ = ""
exec(open("{}/_version.py".format(MOD_NAME)).read())

# create package install list
# User can set version of ont-pyguppy-client-lib to match guppy version
with open(path.join(path.abspath(path.dirname(__file__)),"requirements.txt")) as f:
    install_requires = [p.strip() for p in f]


setuptools.setup(
    name=PKG_NAME,
    version=__version__,
    url="https://github.com/Psy-Fer/blue-crab",
    author="James Ferguson",
    author_email="j.ferguson@garvan.org.au",
    description="Slow5/Blow5 <-> Pod5 converter",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    python_requires=">=3.8",
    install_requires=install_requires,
    setup_requires=["numpy"],
    entry_points={"console_scripts":["blue-crab=src.blue_crab:main"],},
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
    ],
)
