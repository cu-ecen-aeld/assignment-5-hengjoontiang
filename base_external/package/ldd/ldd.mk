################################################################################
#
# scull
#
################################################################################

LDD_VERSION=1.0
LDD_SITE=../assignment-7-hengjoontiang
LDD_SITE_METHOD=local



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


