################################################################################
#
# scull
#
################################################################################

#LDD_VERSION=1.0
#LDD_SITE=../assignment-7-hengjoontiang
#LDD_SITE_METHOD=local
LDD_VERSION = '5c3cae6' 
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
#LDD_SITE = 'git@github.com:cu-ecen-aeld/assignment-7-hengjoontiang.git'

LDD_SITE = '../assignment-7-hengjoontiang/'
#git@github.com:cu-ecen-aeld/assignment-7-hengjoontiang.git
#AESD_ASSIGNMENTS_SITE = 'https://github.com/cu-ecen-aeld/assignment-7-hengjoontiang.git
#LDD_SITE_METHOD = git
LDD_SITE_METHOD = local
#LDD_GIT_SUBMODULES = YES
#AESD_ASSIGNMENTS_SITE_METHOD = git



# Compile and install the kernel module via the kernel-module infra
LDD_MODULE_SUBDIRS=scull
#LDD_MODULE_SUBDIRS = .
#LDD_MODULE_MAKE_OPTS = KERNELDIR=$(LINUX_DIR)
#TARGET_CROSS=aarch64-buildroot-linux-gnu-
#define LDD_BUILD_CMDS
    
#    $(MAKE) $(TARGET_CONFIGURE_OPTS) KDIR=$(LINUX_DIR) M=$(@D)  modules
#endef

#define LDD_MODULE_BUILD_CMDS
#        $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
#	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
#endef
#define LDD_MODULE_INSTALL_TARGET_CMDS
#	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
#	$(INSTALL) -m 0755 $(BUILD_DIR)/ldd-$(LDD_VERSION)/scull/*.o $(BR2_EXTERNAL)/rootfs_overlay/modules
#	$(INSTALL) -m 0755 $(BUILD_DIR)/ldd-$(LDD_VERSION)/scull/*.ko $(BR2_EXTERNAL)/rootfs_overlay/modules
	#$(INSTALL) -m 0755 $(BR2_EXTERNAL)/rootfs_overlay/S98lddmodules $(TARGET_DIR)/etc/init.d/S98lddmodules
#endef
$(eval $(kernel-module))
$(eval $(generic-package))


