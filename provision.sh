#!/bin/sh
########################################################################
# Prepare virtual machine for developing with Boost.
########################################################################
set -e


# required by https://github.com/boostorg/boost/wiki/Getting-Started
readonly NAME=${1?"Your name?"}
git config --global user.name "${NAME}"
readonly EMAIL=${1?"Your email address?"}
git config --global user.email ${EMAIL}
git config --global core.autocrlf input


readonly SRC=boost
git clone --recursive https://github.com/boostorg/boost.git ${SRC}
cd ${SRC}
git checkout develop # or whatever branch you want to use


readonly BIN=${HOME}/install
./bootstrap.sh --prefix=${BIN}
./b2 headers
./b2 --with-test variant=debug install
