
##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

#TODO: Fill up the contents below in order to reference your assignment 3 git contents
#AESD_ASSIGNMENTS_VERSION = 'assignment-5-part-1'
#remember to use the code, rather than english word tag
AESD_ASSIGNMENTS_VERSION = '885dd66'
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
#AESD_ASSIGNMENTS_SITE = 'git@github.com:cu-ecen-aeld/assignments-3-and-later-hengjoontiang.git'
AESD_ASSIGNMENTS_SITE = 'https://github.com/cu-ecen-aeld/assignments-3-and-later-hengjoontiang.git'
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES


define AESD_ASSIGNMENTS_BUILD_CMDS
	#$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app
	#echo "$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/server"
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/server
endef

# TODO add your writer, finder and finder-test utilities/scripts to the installation steps below
define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	echo "@D=$(@D)"
	echo "${HOME}"
	$(INSTALL) -d 0755 $(@D)/conf/ $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -m 0755 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -m 0755 $(@D)/assignment-autotest/test/assignment5-buildroot/* $(TARGET_DIR)/bin
	
	#additional requirements 
	$(INSTALL) -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/finder-test.sh $(TARGET_DIR)/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/bin
	
	echo "@D=$(INSTALL) -m 0755 $(@D)/server/aesdsocket $(TARGET_DIR)/bin"
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket $(TARGET_DIR)/bin
	echo "$(INSTALL) -m 0755 $(@D)/server/aesdsocket-start-stop $(TARGET_DIR)/etc/init.d/S99aesdsocket"
	echo "display contents aesdsocket-start-stop"
	cat $(@D)/server/aesdsocket-start-stop
	
	
	
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket-start-stop $(TARGET_DIR)/etc/init.d/S99aesdsocket
	#cp /home/hengjt/Desktop/Training/Coursera/LinuxSystemProgrammingandIntroductiontoBuildroot/Assignment5/assignment-5-part-2/server/aesdsocket-start-stop $(TARGET_DIR)/etc/init.d/S99aesdsocket
	
	
endef

$(eval $(generic-package))
