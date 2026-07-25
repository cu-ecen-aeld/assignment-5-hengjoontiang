################################################################################
#
# scull
MISC_MODULES_VERSION=1.0
MISC_MODULES_SITE=../assignment-7-hengjoontiang
MISC_MODULES_SITE_METHOD=local
MISC_MODULES_DEPENDENCIES=linux


# Compile and install the kernel module via the kernel-module infra
MISC_MODULES_MODULE_SUBDIRS=misc-modules
#LDD_MODULE_SUBDIRS = .
#LDD_MODULE_MAKE_OPTS = KERNELDIR=$(LINUX_DIR)
#TARGET_CROSS=aarch64-buildroot-linux-gnu-
#define MISC_MODULES_BUILD_CMDS
#    $(MAKE) $(TARGET_CONFIGURE_OPTS) KDIR=$(LINUX_DIR) M=$(@D) modules
    
#endef
#define MISC_MODULES_MODULE_BUILD_CMDS
#        $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
#	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) modules
#endef
#define MISC_MODULES_MODULE_INSTALL_TARGET_CMDS
#	$(MAKE) $(LINUX_MAKE_FLAGS) -C $(LINUX_DIR) M=$(@D) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
#	$(INSTALL) -m 0755 $(BUILD_DIR)/misc_modules-$(MISC_MODULES_VERSION)/misc-modules/*.o $(BR2_EXTERNAL)/rootfs_overlay/modules
#	$(INSTALL) -m 0755 $(BUILD_DIR)/misc_modules-$(MISC_MODULES_VERSION)/misc-modules/*.ko $(BR2_EXTERNAL)/rootfs_overlay/modules
	#$(INSTALL) -m 0755 $(BUILD_DIR)/misc_modules-$(MISC_MODULES_VERSION)/misc-modules/hello.ko $(BR2_EXTERNAL)rootfs_overlay/modules
#endef
$(eval $(kernel-module))
$(eval $(generic-package))




