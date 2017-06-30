.. vim: set expandtab: tw=80

========================
A Vagrant Box for CentOS
========================

The master branch of this repository contains the tools to create a minimal
CentOS Vagrant box. Other branches contain different applications:

  - cpython defines a virtual machine for working on `Cpython`_
  - boost-devel defines a virtual machine for working on `Boost`_
  - reviewboard defines a basic `Review Board`_ virtual machine

This implementation stores several passwords and key pairs in the credentials
directory.  This directory is located within the directory used to make the box.

Generating key pairs and passwords eliminates the need for the public (insecure)
Vagrant SSH key pair.

Encrypted password hashes appear in the generated Kickstart file (called
ks.cfg).  The generated Kickstart file only enough instructions to enable
Vagrant. Other required instructions are in the scripts identified in the Packer
template file (centos.json).

=====================
Build the Vagrant Box
=====================

-------------
Prerequisites
-------------

Install the following prerequisites on the host.

  - GNU Make 3.81
  - Packer 0.10.1
  - Vagrant 1.8.1
  - VirtualBox 5.0.20
  - Python's passlib

Using Python's `virtualenv`_?  `make install` takes care of Python dependencies.
It will not install Python modules into anything other than a virtual environment.

To set up a Python virtual environment run::

  mkvirtualevn vagrant
  workon vagrant

--------
Building
--------

On the host, run::

        > make install all BOX_NAME=foo-centos-x86_64 PACKER_TEMPLATE=centos.json PACKER_VARS=centos-x86_64-vars.json

where

 - BOX_NAME identifies the Vagrant box.
 - PACKER_TEMPLATE identifies the Packer template used to generate the Vagrant box.
 - PACKER_VARS identifies the Packer variables requried by PACKER_TEMPLATE.

The above make command creates the Vagrant box foo-centos-x86_64_virtualbox.box--a
Vagrant box relying on Virtual Box as a provider.

-----
Using
-----

On the host, run::

        > cd flatfoot/foo-centos-x86_64 # organization and box name
        > vagrant up
        > vagrant ssh

.. _Boost: http://www.boost.org
.. _Cpython: http://cython.org
.. _Review Board: https://www.reviewboard.org
.. _virtualenv: https://virtualenv.pypa.io/en/stable/
