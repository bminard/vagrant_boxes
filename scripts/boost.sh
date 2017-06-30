#!/bin/sh
#-------------------------------------------------------------------------------
# Install Boost dependencies.
#-------------------------------------------------------------------------------
set -xe


# Required by https://github.com/boostorg/boost/wiki/Getting-Started
yum --assumeyes install gdb
yum --assumeyes install git
yum --assumeyes install gcc-c++
yum --assumeyes install python-devel
