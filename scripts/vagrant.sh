#!/bin/sh
#-------------------------------------------------------------------------------
# Minimally prepare virtual machine for use by Vagrant.
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
