#!/bin/sh
#-------------------------------------------------------------------------------
# Minimally prepare virtual machine for use by Vagrant.
#-------------------------------------------------------------------------------
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
set -xe


function command {
	local command=${1}; shift
	local service=${1}; shift
	/usr/bin/systemctl ${command} ${service} \
		&& /usr/bin/systemctl status ${service} | egrep -q "Active: active"
	if [ $? -ne 0 ]; then
		exit 1
	fi
}


function start {
	command start ${1}
}


function enable {
	/usr/bin/systemctl enable ${1}
	start ${1}
}


enable firewalld.service


yum update -y


# Install deltarpm package first.
yum --assumeyes install deltarpm


yum --assumeyes install sudo


# Enable NFS.
firewall-cmd --zone=public --permanent --add-service=nfs
firewall-cmd --zone=public --permanent --add-service=mountd
firewall-cmd --zone=public --permanent --add-service=rpc-bind
firewall-cmd --reload
