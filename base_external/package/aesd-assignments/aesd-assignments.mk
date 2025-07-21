
##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

#TODO: Fill up the contents below in order to reference your assignment 3 git contents
AESD_ASSIGNMENTS_VERSION = 'assignment-4-part-1'
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
AESD_ASSIGNMENTS_SITE = 'git@github.com:cu-ecen-aeld/assignments-3-and-later-hengjoontiang.git'
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

define AESD_ASSIGNMENTS_BUILD_CMDS
	#$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app
endef

# TODO add your writer, finder and finder-test utilities/scripts to the installation steps below
define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	$(INSTALL) -d 0755 $(@D)/conf/ $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -m 0755 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -m 0755 $(@D)/assignment-autotest/test/assignment4/* $(TARGET_DIR)/bin
	
	#additional requirements 
	$(INSTALL) -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/finder-test.sh $(TARGET_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/bin
	
	#set up the dhcp
	#echo  "auto eth0" >> $(TARGET_DIR)/etc/network/interfaces
	#echo  "iface eth0 inet dhcp" >> $(TARGET_DIR)/etc/network/interfaces
	#echo  "auto wlp2s0" >> $(TARGET_DIR)/etc/network/interfaces
	#echo  "iface wlp2s0 inet dhcp" >> $(TARGET_DIR)/etc/network/interfaces
	
	#check to make sure that we have /root/.ssh/authorized_kesy file created
	#mkdir -p $(TARGET_DIR)/root/.ssh
	#chmod 0700 $(TARGET_DIR)/root/.ssh
	#touch $(TARGET_DIR)/root/.ssh/authorized_keys
	#chmod 0600 $(TARGET_DIR)/root/.ssh/authorized_keys
	#mkdir -p $OVERLAY_FS/root/.ssh
	#touch $OVERLAY_FS/root/.ssh/authorized_keys
	#chmod 0700 $OVERLAY_FS/root/.ssh
	#chmod 0600 $OVERLAY_FS/root/.ssh
	

	#ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "[localhost]:10022"
	#ssh-keyscan -p10022 -H localhost >> "${HOME}/.ssh/known_hosts"
	#ssh-copy-id -i ${HOME}/.ssh/ user@host
	#ssh-copy-id -p 10022 root@localhost
	
	#generate a set of keys, copy pub key to ~/.ssh/authorized_keys
	#echo "y" | ssh-keygen -t ed25519 -b 256 -N '' -f ${HOME}/.ssh/id_ed25519
	#echo "y" | cp "${HOME}/.ssh/id_ed25519.pub" $(TARGET_DIR)/root/.ssh/authorized_keys
	#chmod 0600 $(TARGET_DIR)/root/.ssh/authorized_keys
	
endef

$(eval $(generic-package))
