#!/bin/sh
#-------------------------------------------------------------------------------
# Install Cpython dependencies.
#-------------------------------------------------------------------------------
set -xe


# Required by https://docs.python.org/devguide/setup.html.
yum --assumeyes install mercurial
yum --assumeyes install yum-utils


# Required to build Cpython modules.
yum --assumeyes install bzip2-devel
yum --assumeyes install gdbm-devel
yum --assumeyes install libffi-devel
yum --assumeyes install ncurses-devel
yum --assumeyes install openssl-devel
yum --assumeyes install readline-devel
yum --assumeyes install sqlite-devel
yum --assumeyes install tk-devel
yum --assumeyes install xz-devel
yum --assumeyes install zlib-devel


# Required by https://docs.python.org/devguide/docquality.html.
yum --assumeyes install git

# Required to build devguide.
curl https://bootstrap.pypa.io/get-pip.py | python
pip install -U Sphinx
