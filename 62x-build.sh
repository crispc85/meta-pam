#!/bin/bash
#
# Yocto build script for the MitySOM-AM62x
# Expected to be ran from within crops/poky:ubuntu-22.04 docker /work directory
set -e
set -x

###############################################################################
#			CUSTOMIZABLE PARAMETERS
###############################################################################
DEPLOY_DIR=${PWD}/deploy

###############################################################################
#			DO NOT MODIFY BELOW THIS
###############################################################################

# export MACHINE=am62xx-evm
export MACHINE=mitysom-am62x

# ./docker-poky.sh ./62x-setup.sh should be run first

pushd build

source conf/setenv

# When running the build on a dev machine, yocto can starve the system of resources
# running the build at a lower priority can help prevent this and keep the system responsive
# It may also help the oom-killer prioritize the bitbake processes if the system runs out of memory
# This should be completely fine on a dedicated build machine as well
renice -n 10 -p $$

# Build machines with a large number of processor cores but limited memory (<64GB?) may 
# need to limit the number of parallel tasks executed by BitBake. This can be
# done by setting the BB_NUMBER_THREADS and PARALLEL_MAKE variables
# Yocto seems to recommend 2GB of free RAM per core
# Then we can low the number of seperate tasks that bitbake will run at once.
# tisdk-base-image seems safe to run with a high number of threads
export BB_NUMBER_THREADS=$(nproc)
# Tell make to look at load average and not just number of jobs
# Keeping the load average at the number of cores should keep the system responsive 
# and reduce the chance of running out of memory
export PARALLEL_MAKE="-j $(nproc) -l $(nproc)"

# Build base image
bitbake tisdk-base-image
# Build default image
# The qt build, vulkan, llvm, opengl, and nodejs builds seem to use the most memory
#bitbake --continue tisdk-default-image
# Build sdk
#bitbake meta-toolchain-arago-tisdk

# Clean deploy directory
rm -rf "${DEPLOY_DIR}"
mkdir -p "${DEPLOY_DIR}"

# Deploy artifacts
# SDK 09 moved artifacts to deploy-ti
cd deploy-ti/images/$MACHINE/ || cd arago-tmp-*/deploy/images/$MACHINE/

cp tiboot3.bin tiboot3-am62x-gp-evm.bin tiboot3-am62x-hs-evm.bin tiboot3-am62x-hs-fs-evm.bin "${DEPLOY_DIR}"
cp tispl.bin			"${DEPLOY_DIR}"
cp u-boot.img			"${DEPLOY_DIR}/"
cp uEnv.txt				"${DEPLOY_DIR}/"
# Deploy SPL image with usb boot support
cp u-boot-spl.bin		"${DEPLOY_DIR}/"
# Deploy kernel and modules
[ -e vmlinux.gz ] && cp vmlinux.gz "${DEPLOY_DIR}/"
[ -e Image ] && cp Image  "${DEPLOY_DIR}/"
[ -e zImage ] && cp zImage "${DEPLOY_DIR}/"
cp modules-${MACHINE}.tgz "${DEPLOY_DIR}/"
# Deploy device tree
cp ./*.dtb* 			"${DEPLOY_DIR}/"
# Rootfs
cp ./*rootfs*.tar.xz 		"${DEPLOY_DIR}/"
cp ./*.manifest 			"${DEPLOY_DIR}/"
cp ./*rootfs.wic.xz 		"${DEPLOY_DIR}/"
# Rename .wic to .img and package sdcard images into zip files
# Script is deployed by recipe zip-wic-images.bb
# ./zip-wic-images.sh
# # Move zipped images to DEPLOY_DIR
# for f in *.img.zip; do
# 	mv "$f" "${DEPLOY_DIR}/"
# done
