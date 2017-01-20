#!/bin/sh
#-------------------------------------------------------------------------------
# Zero fill the dynamic hard disk to minimize size.
#-------------------------------------------------------------------------------
set -xe


yum --assumeyes update
yum --assumeyes clean all
dd if=/dev/zero of=/EMPTY bs=1M \
	|| rm -f /EMPTY
