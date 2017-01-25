#!/bin/sh
#-----------------------------------------------------------------------
# Provision for Cpython development.
#-----------------------------------------------------------------------
# The MIT License (MIT)
# Copyright (c) 2017 Brian Minard
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#-------------------------------------------------------------------------------
readonly NAME=${1?"Name?"}; shift
readonly EMAIL=${1?"Email address?"}; shift


function build {
	hg clone https://hg.python.org/cpython
	cd ${HOME}/cpython
	./configure --with-pydebug
	make -s -j2
	./python -m test -j3


	echo **********************************************************
	echo *** Modules not built: add dependencies to cpython.sh. ***
	echo **********************************************************
}


function devguide {
	git clone https://github.com/python/devguide.git
	cd ${HOME}/devguide
	make html
}


cd ${HOME}
cat<<_EOF > ${HOME}/.hgrc
[ui]
username = ${NAME} ${EMAIL}
_EOF


git config --global user.name "${NAME}"
git config --global user.email ${EMAIL}


{
	build
	devguide
} 2>&1 | tee output.`date +"%Y_%m_%d_%H_%M"`.log
