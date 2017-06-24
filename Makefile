#-------------------------------------------------------------------------------
# Provision a Vagrant Box with CentOS.
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
.PHONY: all
all: check add-box


# Top-level name for Vagrant box hierarchy.
ORGANIZATION?=flatfoot


# Unique prefix for Vagrant box name.
ifndef BOX_NAME
$(error Use BOX_NAME to name the Vagrant Box.)
endif


ifndef PACKER_TEMPLATE
$(error Use PACKER_TEMPLATE to identify the Packer template used to generate the Vagrant box.)
endif

ifndef PACKER_VARS
$(error Use PACKER_VARS to identify the Packer variables requried by PACKER_TEMPLATE.)
endif


TIMESTAMP=timestamp.${PACKER_VARS}
.PHONY: check
check: ${TIMESTAMP}
${TIMESTAMP}: ${PACKER_VARS} ${PACKER_TEMPLATE}
	packer validate -var-file=$^ && touch $@


WHOAMI=$(shell whoami)
GROUP=$(shell groups $(whoami) | cut -d' ' -f1)
CREDENTIALS_DIR=credentials
${CREDENTIALS_DIR}:
	mkdir -pm 0700 $@ && chown ${WHOAMI}:${GROUP} $@


ROOT_PASSWORD?=${CREDENTIALS_DIR}/root_password
${ROOT_PASSWORD}: | ${CREDENTIALS_DIR}
	openssl rand -hex 13 > $@ && chmod 0600 $@


VAGRANT_PRIVATE_KEY?=${CREDENTIALS_DIR}/vagrant_ssh_key
VAGRANT_PUBLIC_KEY?=${VAGRANT_PRIVATE_KEY}.pub
${VAGRANT_PRIVATE_KEY} ${VAGRANT_PUBLIC_KEY}: | ${CREDENTIALS_DIR}
	ssh-keygen -C vagrant@`hostname` -N '' -f ${VAGRANT_PRIVATE_KEY}


BUILDER=$(shell packer inspect ${PACKER_TEMPLATE} | sed -ne '/^$$/d' -Ee 's/[[:space:]]*//g' -Ee '/^Builders:/,/^[[:alnum:]]+:/p' | sed -e '/^.*:/d')
BOX_DIR=${ORGANIZATION}/${BOX_NAME}
${BOX_DIR}:
	mkdir -p $@ && chown ${WHOAMI}:${GROUP} $@
VAGRANT_BOX=${BOX_DIR}/${BOX_NAME}_virtualbox.box
.PHONY: add-box create-box destroy-box halt-box
add-box: destroy-box create-box | ${BOX_DIR}
	vagrant box add --force --name ${BOX_NAME} file://${VAGRANT_BOX}
	@echo "**************************************************"
	@echo "*** Use vagrant up to run the virtual machine. ***"
	@echo "**************************************************"
VAGRANT_FILE=${BOX_DIR}/Vagrantfile
create-box: ${BUILDER} ${VAGRANT_FILE}
${VAGRANT_FILE}: Vagrantfile.sed ${TIMESTAMP} | ${BOX_DIR}
	vagrant init --minimal ${BOX_NAME} --output - file://${VAGRANT_BOX} | sed -f $< > $@
	@echo "******************************************************************"
	@echo "*** Don't forget to place the Vagrantfile under source control ***"
	@echo "******************************************************************"
.PHONY: virtualbox-iso
virtualbox-iso: ${VAGRANT_BOX}
${VAGRANT_BOX}: ${PACKER_VARS} ${PACKER_TEMPLATE} ${VAGRANT_PRIVATE_KEY}
	packer build -var 'ssh_private_key=${VAGRANT_PRIVATE_KEY}' \
	        -var 'vm_name=${BOX_NAME}' \
	        -var 'box_name=${VAGRANT_BOX}' \
		-var-file=${PACKER_VARS} ${PACKER_TEMPLATE}
destroy-box: halt-box
	! [ -f ${VAGRANT_FILE} ] || (cd ${BOX_DIR}; vagrant destroy --force)

# The halt-box target does not handle aborted virtual machines because
# the execution context of this target is unknown. Recovery may be
# "vagrant up" or "vagrant destroy".
halt-box:
	! [ -f ${VAGRANT_FILE} ] || (cd ${BOX_DIR}; vagrant status | egrep -q "default[[:space:]]+running" && vagrant halt \
		|| vagrant status | egrep -q "default[[:space:]]+(poweroff|not created)")


# The Packer template also defines PRESEED_CONF_DIR.
PRESEED_CONF_DIR=http
PRESEED_CONF_FILE=$(shell sed -ne '/installer_conf/p' ${PACKER_VARS} | sed -Ee 's/[[:space:]]+".+":[[:space:]]+"(.*)",/\1/g')
PRESEED_CONF=${PRESEED_CONF_DIR}/${PRESEED_CONF_FILE}


PACKER_TEMPLATE_PROVISIONERS=scripts/vagrant.sh \
	scripts/zerofill_disk.sh
${PACKER_TEMPLATE}: ${PRESEED_CONF} ${PACKER_TEMPLATE_PROVISIONERS}
	touch $@
${PRESEED_CONF}: | ${PRESEED_CONF_DIR}
${PRESEED_CONF_DIR}:
	mkdir -p $@
${PRESEED_CONF}: kickstart.sh ${ROOT_PASSWORD} ${VAGRANT_PUBLIC_KEY}
	sh kickstart.sh --rootpw ${ROOT_PASSWORD} ${VAGRANT_PUBLIC_KEY} > $@


# Remove all files (including Packer caches).
.PHONY: realclean
realclean: clean
	-rm -fr packer_cache


# Remove files that take a long time to create (including Vagrant Boxes,
# Vagrant Box prerequisites and user credentials).
.PHONY: clean
clean: destroy-box mostlyclean
	-vagrant box remove ${BOX_NAME}
	-rm -fr ${CREDENTIALS_DIR} ${PRESEED_CONF_DIR} ${VAGRANT_BOX} ${VAGRANT_FILE}


# Remove files that are created quickly.
.PHONY: mostlyclean
mostlyclean:
	-rm ${PRESEED_CONF} ${TIMESTAMP}


.PHONY: install python-virtual-environment virtual-box-additions
install: python-virtual-environment \
	virtual-box-additions
python-virtual-environment: virtualenv.sh
	sh virtualenv.sh passlib
virtual-box-additions:
	vagrant plugin install vagrant-vbguest
