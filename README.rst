.. vim: set expandtab: tw=80

========================
A Vagrant Box for CentOS
========================

The master branch of this repository contains the tools to create a minimal
CentOS Vagrant box. Other branches contain different applications:

  - cpython defines a virtual machine for working on `Cpython`_
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

        > make install all BOX_NAME=foo

BOX_NAME defines a prefix to the Vagrant box name. The remainder of the name identifies
the operating system and architecture.

-----
Using
-----

On the host, run::

        > vagrant up
        > vagrant ssh

.. _Cpython: http://cython.org
.. _Review Board: https://www.reviewboard.org
.. _virtualenv: https://virtualenv.pypa.io/en/stable/
