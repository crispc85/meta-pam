#!/bin/bash
#
# Yocto setup script for the MitySOM-AM62X using a custom layer
# Expected to be ran from within crops/poky:ubuntu-22.04 docker /work directory
# ./docker-poky.sh ./62x-setup.sh
set -e
set -x

###############################################################################
#			CUSTOMIZABLE PARAMETERS
###############################################################################

# export MACHINE=am62xx-evm
export MACHINE=mitysom-am62x

if [ "$1" == "--next" ]
then
	./oe-layertool-setup.sh -f configs/processor-sdk/processor-sdk-10.00.07-cl-next-config.txt
else
	./oe-layertool-setup.sh -f sources/meta-pam/configs/processor-sdk-10.00.07-cl-config.txt
fi

pushd build
source conf/setenv
# bitbake-layers add-layer ../sources/${CUSTOM_LAYER}


# echo 'IMAGE_ROOTFS_SIZE = "11000000"'  >> conf/local.conf
# echo 'IMAGE_OVERHEAD_FACTOR = "1.0"'  >> conf/local.conf
# echo 'IMAGE_ROOTFS_EXTRA_SPACE = "0"' >> conf/local.conf

# if [ ! -z ${DEVICE_TREE} ]; then
# 	TEMP_VAR="KERNEL_DEVICETREE  = \"${DEVICE_TREE}.dtb\""
# 	echo "${TEMP_VAR}" >> conf/local.conf
# fi
# if [ ! -z ${UENV_FILE} ]; then
# 	echo 'IMAGE_BOOT_FILES  += "uEnv.txt"' >> conf/local.conf
# fi
