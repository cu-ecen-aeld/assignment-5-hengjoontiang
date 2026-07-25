#!/bin/sh
# Shared definitions for buildroot scripts
#HOME=$(pwd)
#echo HOME=${HOME}
# The defconfig from the buildroot directory we use for qemu builds
QEMU_DEFCONFIG=configs/qemu_aarch64_virt_defconfig
# The place we store customizations to the qemu configuration
MODIFIED_QEMU_DEFCONFIG=base_external/configs/aesd_qemu_defconfig
# The defconfig from the buildroot directory we use for the project
AESD_DEFAULT_DEFCONFIG=${QEMU_DEFCONFIG}
AESD_MODIFIED_DEFCONFIG=${MODIFIED_QEMU_DEFCONFIG}
AESD_MODIFIED_DEFCONFIG_REL_BUILDROOT=../${AESD_MODIFIED_DEFCONFIG}
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_USE_DEFCONFIG=y
BR2_LINUX_KERNEL_DEFCONFIG="aarch64_efi"
#BR2_TARGET_ROOTFS_EXT2_SIZE=10
#BR2_PACKAGE_HOST_ENVIRONMENT_SETUP=""
