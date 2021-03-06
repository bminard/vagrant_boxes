#!/bin/sh
#-------------------------------------------------------------------------------
# Provision Kickstart configuration file.
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
function usage {
	echo "Usage: ${0} --rootpw <password> <vagrant public ssh key>"
	exit 1
}


ROOT_PASSWORD=""
while [[ $# -gt 2 ]]; do
	key="$1"
	case $key in
		--rootpw)
			ROOT_PASSWORD="$2"
			shift
			;;
		*)
			usage
			;;
	esac
	shift
done
readonly VAGRANT_PUBLIC_KEY=${1}; shift


[ -f "${ROOT_PASSWORD}" ] \
	&& [ -f "${VAGRANT_PUBLIC_KEY}" ] \
	|| usage


readonly PLAINTEXT_ROOT_PASSWORD=`cat ${ROOT_PASSWORD}`
readonly ENCRYPTED_ROOT_PASSWORD=`echo "from passlib.hash import sha512_crypt; print sha512_crypt.encrypt('${PLAINTEXT_ROOT_PASSWORD}')" | python -`
if [ -z "${ENCRYPTED_ROOT_PASSWORD}" ]; then
	exit 1
fi


cat<<_EOF
# Generated by ${0} (commit `git log -n 1 --pretty="%h" ${0}`) on `date`. Do NOT edit.


install
text
cdrom
skipx
lang en_CA.UTF-8
keyboard us
timezone UTC
rootpw --iscrypted ${ENCRYPTED_ROOT_PASSWORD}
user --name=vagrant
auth --enableshadow --passalgo=sha512 --kickstart
services --enabled=ssh
firewall --enabled 
selinux --permissive
bootloader --location=mbr
zerombr
clearpart --all --initlabel
autopart
firstboot --disable
reboot


# Keep this package list short to avoid SSH timeouts during Vagrant Box
# creation. Use the Packer template to install additional packages.
%packages --instLangs=en_CA.utf8 --nobase --ignoremissing --excludedocs
authconfig
system-config-firewall-base
openssh-server
openssh-clients
%end


%post --log=/root/ks.log


cat <<EOF > /etc/sudoers.d/vagrant
vagrant ALL=(ALL) NOPASSWD: ALL
Defaults:vagrant !requiretty
EOF
chmod 0440 /etc/sudoers.d/vagrant

mkdir -pm 700 /home/vagrant/.ssh
cat <<EOK >/home/vagrant/.ssh/authorized_keys
`cat ${VAGRANT_PUBLIC_KEY}`
EOK
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
%end
_EOF
