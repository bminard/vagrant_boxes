#!/bin/sh
#-------------------------------------------------------------------------------
# Start ntpd.
#-------------------------------------------------------------------------------
set -xe


yum --assumeyes install ntp
systemctl enable ntpd
systemctl start ntpd
